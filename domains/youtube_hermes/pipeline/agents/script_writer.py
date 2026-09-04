"""
Subagent 3: Script Writer
Converts ContentPlan into a 4-5 clip VideoScript with Hinglish dialogue,
highly detailed Flow prompts, visual cues, and thumbnail concept.

Uses a two-stage LLM approach:
1. Context-setting prompt establishing channel persona, style, and requirements
2. Clip-by-clip detailed generation with exact visual specs, moods, expressions, lighting
"""
from __future__ import annotations
import json
import re
from typing import Any, List, Optional, Dict

from domains.youtube_hermes.pipeline.shared.models import (
    ClipScript, ContentPlan, PipelineRun, PipelineStage, VideoScript
)
from domains.youtube_hermes.pipeline.shared.llm import get_nvidia_client, get_system_prompt
from domains.youtube_hermes.pipeline.shared.storage import db


class ScriptWriterAgent:
    """Generates VideoScript from ContentPlan using NVIDIA LLM with detailed context and clip-by-clip generation."""

    def __init__(self):
        self.llm = get_nvidia_client(agent_name="script_writer")
        self.system_prompt = get_system_prompt("script_writer")

    def write_script(self, run: PipelineRun) -> VideoScript:
        """Main entry: generate VideoScript from ContentPlan."""
        plan = run.content_plan
        if not plan:
            raise ValueError("No ContentPlan available for script writing")

        # Try LLM generation with two-stage approach
        try:
            script = self._generate_with_llm_two_stage(run, plan)
            if script and self._validate_script(script, plan):
                run.video_script = script
                run.current_stage = PipelineStage.SCRIPT_REVIEW
                db.update_run(run)
                db.save_artifact(run.run_id, "script_write", "result", script.to_dict())
                return script
        except Exception as e:
            print(f"[SCRIPT_WRITER] LLM failed: {e}, using fallback")

        # Fallback to topic-aware template
        script = self._fallback_script(run, plan)
        run.video_script = script
        run.current_stage = PipelineStage.SCRIPT_REVIEW
        db.update_run(run)
        db.save_artifact(run.run_id, "script_write", "result", script.to_dict())
        return script

    def _generate_with_llm_two_stage(self, run: PipelineRun, plan: ContentPlan) -> Optional[VideoScript]:
        """Two-stage LLM generation: context setting → autonomous clip structure → clip-by-clip detailed prompts.
        
        The Script Writer AUTONOMOUSLY decides the 4-clip/15s structure based on the full plan.
        Uses NVIDIAClient.generate() and generate_json() methods directly.
        """
        
        # STAGE 1: Build and send the master context prompt
        context_prompt = self._build_master_context_prompt(plan)
        
        # Use generate() for the context acknowledgment (text response)
        context_ack = self.llm.generate(
            prompt=context_prompt,
            system_prompt=self.system_prompt,
            temperature=0.7,
            max_tokens=500
        ).strip()
        
        print(f"[SCRIPT_WRITER] Context acknowledged: {context_ack[:100]}...")
        
        # STAGE 2: Get AUTONOMOUS clip structure from LLM (not planner's sections)
        structure_prompt = self._build_structure_prompt(plan)
        
        # Build full conversation for structure decision
        structure_full_prompt = f"{context_prompt}\n\n{context_ack}\n\n{structure_prompt}"
        structure_response = self.llm.generate_json(
            prompt=structure_full_prompt,
            system_prompt=self.system_prompt,
            temperature=0.7,
            max_tokens=2000
        )
        
        structure_data = self._parse_structure_response(json.dumps(structure_response) if isinstance(structure_response, dict) else structure_response)
        if not structure_data or "clips" not in structure_data:
            return None
            
        clip_sections = structure_data["clips"]  # List of dicts with section, focus, approx_words
        if len(clip_sections) < 3 or len(clip_sections) > 5:
            return None
        
        # STAGE 3: Generate each clip with detailed prompts
        clips = []
        for i, clip_info in enumerate(clip_sections[:4], 1):  # Max 4 clips = 60s
            clip_prompt = self._build_clip_prompt(plan, i, clip_info, clip_sections)
            
            # For clip 1, include context reference. For others, just the clip prompt
            # since context was already established in the conversation
            if i == 1:
                clip_full_prompt = f"{context_prompt}\n\n{context_ack}\n\n{clip_prompt}"
            else:
                clip_full_prompt = clip_prompt
            
            clip_response = self.llm.generate_json(
                prompt=clip_full_prompt,
                system_prompt=self.system_prompt,
                temperature=0.7,
                max_tokens=3000
            )
            
            clip_content = json.dumps(clip_response) if isinstance(clip_response, dict) else clip_response
            clip_data = self._parse_clip_response(clip_content, i)
            
            if clip_data:
                clips.append(ClipScript(
                    clip_index=i,
                    duration_seconds=15,
                    flow_prompt=clip_data.get("flow_prompt", ""),
                    voiceover_text=clip_data.get("voiceover_text", ""),
                    visual_cues=clip_data.get("visual_cues", []),
                    transition_note=clip_data.get("transition_note", "")
                ))
        
        if len(clips) < 3:
            return None
        
        # STAGE 4: Generate metadata (title, description, tags, thumbnail)
        meta_prompt = self._build_metadata_prompt(plan, clips)
        meta_full_prompt = f"{context_prompt}\n\n{context_ack}\n\n{meta_prompt}"
        meta_response = self.llm.generate_json(
            prompt=meta_full_prompt,
            system_prompt=self.system_prompt,
            temperature=0.7,
            max_tokens=2000
        )
        
        meta_data = self._parse_metadata_response(json.dumps(meta_response) if isinstance(meta_response, dict) else meta_response)
        
        return VideoScript(
            topic=plan.topic,
            title=meta_data.get("title", plan.topic[:80]),
            description=meta_data.get("description", f"{plan.topic}. {plan.cta}"),
            tags=meta_data.get("tags", ["JEE", "Preparation", "Strategy"]),
            clips=clips,
            thumbnail_concept=meta_data.get("thumbnail_concept", "TAKE ACTION"),
            google_flow_context_prompt=self._build_google_flow_context_prompt(plan)
        )

    def _build_master_context_prompt(self, plan: ContentPlan) -> str:
        """Build the master context-setting prompt that establishes everything for the AI video generator."""
        return f"""You are an expert prompt engineer for Google Flow / Veo 3 AI video generation, creating YouTube Shorts for a JEE mentoring channel.

================================================================================
CHANNEL & PERSONA CONTEXT (CRITICAL - READ CAREFULLY)
================================================================================
Channel: Yatharth Sachdeva (@YatharthSachdeva23) - JEE/College Admissions Mentor
Persona: "BHAIYA" (Older Brother) - Urgent, empathetic, action-oriented, NO academic teaching
Language: HINGLISH (natural Hindi-English mix, NOT pure English, NOT pure Hindi)
Tone: Brotherly urgency with 🚨 markers, "LAST CHANCE", "BREAKING", "ACT NOW"
Format: Vertical 9:16 Shorts, 45-60 seconds, 4 clips × 15s each
Audience: JEE aspirants (11th/12th grade, droppers), first-year engineering students
Content Pillars: JEE counseling (JAC/JOSAA/IPU/DTU/NSUT/CSAB), spot rounds, college life, prep strategies (MENTORING ONLY - zero syllabus teaching)
CTA Style: GENERIC ONLY - "Like, share, subscribe, comment [topic-specific prompt]" - NO personalized replies ("I'll tell your rank", "I'll reply", "DM me")

================================================================================
AI VIDEO GENERATION CONTEXT (FOR GOOGLE FLOW / VEO 3)
================================================================================
AI Avatar: Pre-defined (talking head, Indian male, early 20s, approachable "bhaiya" vibe)
- You DO NOT define the avatar - it's already set in the avatar system
- You DO define: MOOD, EXPRESSION, CAMERA ANGLE, BODY LANGUAGE, HAND GESTURES, EYE CONTACT
- Background: You SPECIFY exactly (solid color, gradient, relevant b-roll, screen recording, whiteboard, etc.)
- Lighting: You SPECIFY (key light position, rim light, practical lights, color temperature, mood lighting)
- On-screen Elements: Text overlays (exact wording, position, animation), graphics, charts, timelines, calendars
- Audio Layers: Main voiceover (avatar), BACKGROUND VOICES (whispers, crowd murmurs, student voices, notification sounds), SFX (whoosh, pop, clock tick, alarm)
- Transitions: Hard cut, whip pan, zoom, match cut, glitch, dissolve - specify per clip

================================================================================
CURRENT VIDEO SPECIFICATION
================================================================================
TOPIC: {plan.topic}
TARGET AUDIENCE SEGMENT: {self._detect_segment(plan)}
AUDIENCE PAIN POINTS:
{chr(10).join(f"  {i+1}. {p}" for i, p in enumerate(plan.audience_pain_points))}

MYTHS TO BUST:
{chr(10).join(f"  {i+1}. {m}" for i, m in enumerate(plan.myths_misconceptions))}

KEY ANGLES (OUR UNIQUE COVERAGE):
{chr(10).join(f"  {i+1}. {a}" for i, a in enumerate(plan.key_angles))}

STRUCTURE OUTLINE (4 sections × 15s = 60s):
{chr(10).join(f"  {i+1}. {s}" for i, s in enumerate(plan.structure_outline))}

CTA: {plan.cta}
URGENCY HOOKS: {', '.join(plan.urgency_hooks)}

================================================================================
YOUR TASK
================================================================================
I will now give you clip-by-clip prompts. For EACH clip, you must generate a DETAILED Google Flow prompt that includes:

1. FLOW PROMPT (for Google Flow): A single comprehensive paragraph describing:
   - Camera: angle (close-up/medium/wide), movement (static/pan/zoom/whip), focus
   - AI Avatar: exact mood (urgent/empathetic/analytical/encouraging/shocked), expression (eyebrows, mouth, eyes), body language (leaning forward, hand gestures, pointing), eye contact (direct/lens/side)
   - Background: specific setting (solid #color, gradient, b-roll description, screen recording content, whiteboard drawing)
   - Lighting: key light (position, intensity), rim/hair light, practicals, color temp (warm/cool/neutral), mood (high-key/low-key/dramatic)
   - On-screen text: EXACT wording, position (top/middle/bottom/left/right), style (bold/outline/animated), timing
   - Graphics/Elements: charts, timelines, calendars, checklists, progress bars, icons - exact content
   - Audio layers: main voiceover text (Hinglish), BACKGROUND VOICES (describe: who, what they say, volume), SFX (specific sounds)
   - Transition OUT: how this clip ends and leads to next

2. VOICEOVER_TEXT: Exact Hinglish line the avatar speaks (35-40 words for 15s)

3. VISUAL_CUES: Array of 3-5 key on-screen text/graphics for quick reference

4. TRANSITION_NOTE: One-line description of transition to next clip

OUTPUT FORMAT (JSON):
{{
  "flow_prompt": "Talking head, extreme close-up, camera slowly pushes in. AI Avatar: URGENT mood, eyebrows furrowed, eyes wide locked on lens, leaning forward 15°, right hand chops air for emphasis. Background: Deep red gradient (#8B0000 to #000000), subtle pulsing alarm light top-right. Lighting: Hard key light camera-left at 45°, cool rim light camera-right, dramatic low-key. Text overlay TOP: '🚨 LAST CHANCE' bold white with red outline, pulse animation. Text overlay BOTTOM: '5 MONTHS LEFT' yellow bold. SFX: Slow heartbeat thump-thump under voiceover. Background voices: Faint distant student murmurs 'bhaiya... bhaiya...' barely audible. Voiceover: 'Bhaiya, 5 mahine bache hain JEE Main 2027 ke! Mocks abhi se shuru karo!' Transition: Hard cut to medium shot on 'abhi se'.",
  "voiceover_text": "Bhaiya, 5 mahine bache hain JEE Main 2027 ke! Mocks abhi se shuru karo!",
  "visual_cues": ["🚨 LAST CHANCE", "5 MONTHS LEFT", "JEE Main 2027", "HEARTBEAT SFX"],
  "transition_note": "Hard cut on 'abhi se' to medium shot"
}}

================================================================================
RULES (NON-NEGOTIABLE)
================================================================================
- Hinglish is MANDATORY - natural mix like "bhaiya", "mahine", "kar", "hai", "shuru", "abhi se"
- Urgency markers (🚨, LAST CHANCE, NOW, ACT, BREAKING) in EVERY clip
- Background voices: Use strategically - student whispers, notification pings, clock ticks, crowd murmurs
- AI Avatar expressions: Be SPECIFIC - "eyebrows raised, slight smile, nodding" not just "happy"
- Lighting: Always specify key light position, rim light, color temperature
- Text overlays: Exact wording, position, animation style
- NO personalized CTA promises
- Thumbnail concept: <5 words, high contrast, for last 1s overlay
- Each clip = exactly ~15 seconds = ~35-40 words voiceover
- Total 4 clips = 60 seconds max

================================================================================
ACKNOWLEDGMENT REQUIRED
================================================================================
Reply with exactly: "CONTEXT UNDERSTOOD. Ready for clip-by-clip generation. Don't show clip numbers - just generate the clips as I give you prompts one by one."

Understand this whole context now. I will give you each clip prompt one by one and you make it.
"""

    def _build_google_flow_context_prompt(self, plan: ContentPlan) -> str:
        """Build the global context prompt for Omni Flash (Google Flow).
        This is sent ONCE at the start, then clip prompts follow.
        Avatar is pre-defined in Google Flow - don't redefine it."""
        return f"""OMNI FLASH GLOBAL CONTEXT (Google Flow)
================================================================================
ROLE: You are an expert YouTube Shorts video creator with deep experience in viral short-form content, retention optimization, and Omni Flash generation. You know exactly how to craft prompts that produce high-retention, engaging vertical videos.

YOUTUBE CHANNEL: Yatharth Sachdeva (@YatharthSachdeva23)
PERSONA: BHAIYA (Older Brother) - JEE/College Admissions Mentor
STYLE: Hinglish mix, urgency markers (🚨 LAST CHANCE), brotherly empathy, action-oriented
CONTENT: ZERO academic teaching - ONLY mentoring, process guidance, strategies, college life, counseling
FORMAT: Vertical 9:16 YouTube Shorts, 60 seconds total, 4 clips x 15 seconds each

AVATAR: PRE-DEFINED in Google Flow (talking head, Indian male, early 20s, approachable "bhaiya" vibe)
- DO NOT define avatar appearance - already configured in Flow
- You CONTROL: mood, expression, camera angle, body language, gestures, eye contact per clip

VIDEO SPECIFICATION:
- 4 clips x 15s = 60s total
- Hook in first 3 seconds of Clip 1
- Thumbnail overlay in last 1 second of Clip 4
- 150 wpm narration -> ~35-40 words per clip
- Generic CTA only: "Like, share, subscribe, comment"

GLOBAL VISUAL STYLE (apply to all clips unless clip specifies otherwise):
- Camera: Talking head dominant, strategic b-roll/screen recording cutaways
- Lighting: Specify per clip (key light position, rim light, color temp, mood)
- Background: Per clip (gradients, split screens, screen recordings, progress bars)
- Text Overlays: Exact wording, position (TOP/MIDDLE/BOTTOM), style (bold/outline/animated), timing
- Graphics: Charts, timelines, checklists, progress bars - exact content per clip

GLOBAL AUDIO LAYERS (layer into each clip):
- Main: Avatar voiceover (Hinglish, provided per clip)
- Background Voices: Student whispers, crowd murmurs, notification pings, clock ticks (per clip)
- SFX: Heartbeat, whoosh, pop, bell, alarm, tick-tock (per clip)
- Transitions: Hard cut, whip pan, zoom, match cut (specified per clip)

THUMBNAIL: <5 words, ALL CAPS, high contrast, appears last 1s of Clip 4

CURRENT VIDEO:
Topic: {plan.topic}
Target Segment: {self._detect_segment(plan)}
CTA: {plan.cta}
Urgency Hooks: {', '.join(plan.urgency_hooks)}
================================================================================
CLIP PROMPTS FOLLOW (one per clip with complete per-clip specs)

Understand this whole context now. I will give you each clip prompt one by one and you make it.
"""

    def _build_clip_prompt(self, plan: ContentPlan, clip_index: int, clip_info: Dict, all_clips: List[Dict]) -> str:
        """Build detailed prompt for a specific clip using autonomous structure."""
        is_first = clip_index == 1
        is_last = clip_index == len(all_clips[:4])
        next_section = all_clips[clip_index].get("section", "END SCREEN") if clip_index < len(all_clips) else "END SCREEN"

        segment = self._detect_segment(plan)
        urgency = plan.urgency_hooks[0] if plan.urgency_hooks else "🚨 URGENT"

        # Target words for this clip
        target_words = clip_info.get('approx_words', 38)
        min_words = target_words - 2
        max_words = target_words + 3

        # Clip-specific guidance based on position and content focus
        clip_guidance = self._get_clip_guidance_for_structure(plan, clip_index, segment, clip_info)

        return f"""================================================================================
CLIP {clip_index} OF 4 - GENERATE DETAILED FLOW PROMPT
================================================================================
SECTION: {clip_info.get('section', 'Unknown')}
FOCUS: {clip_info.get('focus', 'General content')}
TARGET WORDS: ~{target_words} words (15 seconds at 150 wpm)
NEXT SECTION: {next_section}
IS FIRST CLIP: {is_first}
IS LAST CLIP: {is_last}
SEGMENT: {segment}
PRIMARY URGENCY HOOK: {urgency}

CLIP-SPECIFIC GUIDANCE:
{clip_guidance}

REQUIREMENTS FOR THIS CLIP:
1. Voiceover: EXACT Hinglish, {min_words}-{max_words} words (15s at speaking pace)
2. Flow Prompt: Comprehensive single paragraph with ALL details (camera, character mood/expression/body language, background, lighting, text overlays, graphics, audio layers, transition)
3. Visual Cues: 3-5 key on-screen elements
4. Transition Note: How this leads to next clip

SPECIAL AUDIO LAYER IDEAS FOR THIS CLIP:
- Clip 1 (Hook): Heartbeat SFX, distant student whispers "bhaiya..."
- Clip 2 (Why/What): Notification ping sounds, keyboard typing, page flip
- Clip 3 (How/Strategy): Timer tick-tock, mouse click, whoosh transitions
- Clip 4 (CTA): Subscribe bell sound, crowd cheer faint, final heartbeat

OUTPUT: JSON only with keys: flow_prompt, voiceover_text, visual_cues, transition_note"""

    def _get_clip_guidance(self, plan: ContentPlan, clip_index: int, segment: str) -> str:
        """Return clip-specific creative guidance based on segment and position."""
        topic_lower = plan.topic.lower()
        
        if "mock" in topic_lower:
            return self._mock_strategy_guidance(clip_index)
        elif "backlog" in topic_lower:
            return self._backlog_guidance(clip_index)
        elif "11th" in topic_lower or "20 month" in topic_lower:
            return self._11th_grade_guidance(clip_index)
        elif "drop" in topic_lower or "lower college" in topic_lower:
            return self._drop_vs_college_guidance(clip_index)
        elif "counsel" in topic_lower or "spot" in topic_lower or "round" in topic_lower:
            return self._counseling_guidance(clip_index)
        else:
            return self._generic_guidance(clip_index)

    def _build_structure_prompt(self, plan: ContentPlan) -> str:
        """Build prompt for LLM to autonomously decide the 4-clip/15s structure."""
        return f"""================================================================================
AUTONOMOUS CLIP STRUCTURE DECISION
================================================================================
Based on the full video context above, you must NOW decide the optimal 4-clip structure (each exactly 15 seconds = ~35-40 words voiceover) for this 60-second YouTube Short.

FULL CONTENT TO DISTRIBUTE:
- Topic: {plan.topic}
- Pain Points: {len(plan.audience_pain_points)} items
- Myths to Bust: {len(plan.myths_misconceptions)} items
- Key Angles: {len(plan.key_angles)} items
- CTA: {plan.cta}
- Urgency Hooks: {plan.urgency_hooks}

PLANNER'S SUGGESTED OUTLINE (you may RESTRUCTURE this):
{chr(10).join(f'  {i+1}. {s}' for i, s in enumerate(plan.structure_outline))}

================================================================================
RULES FOR CLIP STRUCTURE:
================================================================================
1. EXACTLY 4 clips × 15 seconds = 60 seconds total (no more, no less)
2. Clip 1 (0-15s): MUST contain the HOOK in first 3 seconds + setup
3. Clip 2 (15-30s): Core content - myths, why it matters, key insights
4. Clip 3 (30-45s): Practical strategy / how-to / actionable steps
4. Clip 4 (45-60s): CTA + urgency + thumbnail concept (last 1 second)
5. Each clip ≈ 35-40 words voiceover at 150 wpm
6. Hook must be in FIRST 3 seconds of Clip 1
7. Thumbnail concept must appear in LAST 1 second of Clip 4
8. Clips must flow seamlessly - cliffhangers between clips
9. NO academic teaching - ONLY mentoring/strategy/process
10. Hinglish mandatory in every clip

================================================================================
YOUR TASK:
================================================================================
Analyze the planner's outline and the full content. Decide the optimal 4-clip breakdown.
You MAY combine, split, or restructure sections to fit exactly 4×15s clips.
For example: If planner says "Hook (0-3s)" + "Why mocks (3-18s)" = 18s total, 
you might put Hook(3s) + part of Why(12s) in Clip 1, remaining Why(3s) + How(12s) in Clip 2, etc.

OUTPUT FORMAT (JSON):
{{
  "clips": [
    {{"section": "Hook + Why mocks matter (part 1)", "focus": "Shock urgency + myth 1-2 busted", "approx_words": 38}},
    {{"section": "Why mocks matter (part 2) + How to attempt", "focus": "Myth 3-5 + practical timer setup", "approx_words": 38}},
    {{"section": "How to attempt (cont.) + Post-mock analysis", "focus": "Full paper strategy + mistake categorization", "approx_words": 38}},
    {{"section": "Post-mock analysis (cont.) + CTA", "focus": "Weak topic adjustment + urgency CTA", "approx_words": 38}}
  ],
  "reasoning": "Brief explanation of how you split the content to fit 4×15s"
}}

Output ONLY valid JSON. No markdown, no explanation."""

    def _parse_structure_response(self, content: str) -> Optional[Dict]:
        """Parse structure JSON from LLM response."""
        try:
            json_match = re.search(r'\{.*\}', content, re.DOTALL)
            if json_match:
                data = json.loads(json_match.group())
            else:
                data = json.loads(content)
            
            if "clips" in data and isinstance(data["clips"], list):
                return data
        except Exception as e:
            print(f"[SCRIPT_WRITER] Structure parse error: {e}")
        return None

    def _mock_strategy_guidance(self, clip_index: int) -> str:
        guidance = {
            1: """HOOK - SHOCK THEM INTO ACTION
- Character: SHOCKED/URGENT - eyes wide, eyebrows high, mouth slightly open, lean forward aggressively
- Background: Deep red → black gradient, pulsing alarm light, digital countdown "5:00:00:00" (months:days:hours:mins)
- Lighting: Harsh top-down key (interrogation style), cool blue rim, dramatic shadows
- Text: TOP '🚨 LAST CHANCE' large red outline pulse. MIDDLE 'MOCKS = DIAGNOSTIC TOOL' white. BOTTOM '5 MONTHS' yellow.
- Background voices: FAINT panicked student voices "syllabus nahi hua... kaise mock...?" overlapping
- SFX: Heartbeat (fast), emergency alert beep every 3s""",
            2: """WHY MOCKS MATTER - MYTH BUSTING WITH ENERGY
- Character: ENERGETIC/MYTH-BUSTER - eyebrows furrowed, confident smirk, chopping hand gestures, pointing at invisible myths
- Background: Split screen - LEFT: "OLD WAY" (student buried in books, gray), RIGHT: "MOCK FIRST" (student confident, green checkmarks)
- Lighting: High-key, bright, energetic - key light front, fill light soft, warm practicals
- Text: TOP 'MYTH vs REALITY'. LEFT column: 'Syllabus first ✗', '90% score ✗', 'More mocks ✗'. RIGHT: 'Gaps first ✓', 'Any score ✓', 'Analysis ✓'
- Background voices: Each myth busted → "POP!" sound + whisper "bakwaas!"
- SFX: Myth bust = balloon pop, Reality = cash register 'cha-ching'""",
            3: """HOW TO ATTEMPT - PRACTICAL DEMO MODE
- Character: PRACTICAL/FOCUSED - calm, nodding, finger counting steps, screen-pointing gesture
- Background: Screen recording of mock test interface (timer top-right, question palette left), avatar picture-in-picture bottom-right
- Lighting: Cool blue key (tech vibe), warm rim on face, screen glow on face
- Text: STEP-BY-STEP overlay as he speaks: '1. SET TIMER', '2. FULL PAPER', '3. MARK GUESSES', '4. TIME/SECTION'
- Background voices: Keyboard clicks, mouse clicks, timer tick-tock (subtle)
- SFX: 'Whoosh' on each step, 'Ding!' on completion""",
            4: """CTA - EVERY MOCK COUNTS - EMOTIONAL PUSH
- Character: ENCOURAGING/BROTHERLY - warm smile, slight nod, hand on heart, direct eye contact, lean back relaxed but urgent
- Background: Warm gradient (orange → gold), subtle particles rising, progress bar filling "MOCK 1 → MOCK 30"
- Lighting: Golden hour warm key, soft fill, rim light halo effect
- Text: TOP 'EVERY MOCK COUNTS'. MIDDLE 'HAR MOCK MATTER KARTA HAI'. BOTTOM CTA animated: 'LIKE • SHARE • SUBSCRIBE • COMMENT YOUR DOUBTS'
- Background voices: Faint cheering "Go! Go!", notification sounds "ping ping", final heartbeat slow and steady
- SFX: Subscribe bell 'ding', final heartbeat thump"""
        }
        return guidance.get(clip_index, "Standard clip - follow general rules")

    def _backlog_guidance(self, clip_index: int) -> str:
        guidance = {
            1: """HOOK - REALITY CHECK WITH EMPATHY
- Character: EMPATHETIC BUT FIRM - slight frown, understanding nod, hand gesture 'stop', lean forward
- Background: Split - LEFT: Calendar with "BACKLOG" red X marks, RIGHT: Clean "70/30 PLAN" green checks
- Lighting: Neutral key, slight drama, practical desk lamp visible
- Text: TOP '🚨 5 MONTHS LEFT'. MIDDLE '11TH BACKLOG + 12TH = ?'. BOTTOM '70/30 STRATEGY'
- Background voices: Student sighs "bahut hai...", mentor whisper "shhh, sun...""",
            2: """MYTHS BUSTED - DIRECT & NO-NONSENSE
- Character: DIRECT/AUTHORITATIVE - finger wag 'no', palm up 'stop', confident posture
- Background: Myth cards FLIP to reality - animated cards rotating
- Lighting: High contrast, each myth = red light, reality = green light
- Text: Animated flip cards: '100% Syllabus ✗' → 'Mock First ✓', 'NCERT Enough ✗' → 'Advanced Needed ✓', '14 Hours ✗' → 'Consistency ✓'
- Background voices: Each flip = 'FLIP' sound, whisper "galat tha...""",
            3: """70/30 STRATEGY - VISUAL FRAMEWORK
- Character: STRUCTURED/TEACHER - whiteboard drawing, pointing, explaining with hands
- Background: Whiteboard with 70/30 pie chart, weekly calendar, high-yield chapter list
- Lighting: Cool white (classroom), key light on board, rim on face
- Text: '70% = 12TH CURRENT', '30% = 11TH HIGH-YIELD', 'MOCK → GAPS → STUDY'
- Background voices: Chalk writing sounds, marker squeak, student "ahaan...""",
            4: """CTA - START TODAY WITH WEEKLY PLAN
- Character: ACTION-ORIENTED - finger guns 'you got this', thumbs up, confident smile
- Background: Weekly calendar Mon-Sun filling up with color codes
- Lighting: Warm, encouraging, golden rim
- Text: 'MON-WED: 12TH', 'THU: 11TH', 'FRI: MOCK', 'SAT: ANALYSIS', 'SUN: WEAK TOPICS'
- Background voices: Calendar 'thud' each day, final cheer"""
        }
        return guidance.get(clip_index, "Standard clip")

    def _11th_grade_guidance(self, clip_index: int) -> str:
        guidance = {
            1: """HOOK - POSITIVE FRAMING, NOT FEAR
- Character: ENCOURAGING BIG BROTHER - warm smile, slight head tilt, welcoming gesture, relaxed but urgent
- Background: Bright gradient (blue → teal), "20 MONTHS" large counter, calendar pages flipping forward
- Lighting: High-key, bright, optimistic - warm key, soft fill
- Text: TOP '🚨 20 MONTHS'. MIDDLE 'START RIGHT, NOT FAST'. BOTTOM 'JEE 2028'
- Background voices: Excited student whispers "20 mahine? kaafi hain!" """,
            2: """11TH MYTHS - CALM BUSTING
- Character: CALM/KNOWING - slight smile, finger counting myths, relaxed posture
- Background: Myth bubbles popping - "Advanced problems", "Coaching day 1", "NCERT basic"
- Lighting: Soft, even, friendly
- Text: Each myth pops → 'REALITY: Foundation First!'
- Background voices: Bubble pop sounds, whisper "sahi hai...""",
            3: """20-MONTH ROADMAP - VISUAL TIMELINE
- Character: STRUCTURED VISIONARY - pointing at timeline, sweeping hand across phases
- Background: Horizontal timeline Phase 1→2→3, school+JEE integrated icons
- Lighting: Professional, cool key, warm rim
- Text: 'PHASE 1: 6M NCERT', 'PHASE 2: 8M PRACTICE', 'PHASE 3: 6M MOCKS', 'SCHOOL+JEE INTEGRATED'
- Background voices: Timeline 'whoosh' each phase, student "clear hai...""",
            4: """CTA - BUILD FOUNDATIONS DAILY
- Character: BROTHERLY PUSH - hand on shoulder (implied), warm eye contact, nod
- Background: Daily habit tracker filling - morning/evening/weekend
- Lighting: Golden hour, warm, intimate
- Text: '2-3 HOURS DAILY', 'MORNING: CONCEPTS', 'EVENING: REVISION', 'WEEKEND: MOCK'
- Background voices: Habit 'check' sounds, final subscribe bell"""
        }
        return guidance.get(clip_index, "Standard clip")

    def _drop_vs_college_guidance(self, clip_index: int) -> str:
        guidance = {
            1: """HOOK - BRUTAL TRUTH, NO SUGARCOATING
- Character: SERIOUS/BROTHERLY TOUGH LOVE - steady gaze, slow head shake, palm down 'stop'
- Background: Dark gradient, rank bands visual (50K-1L green, 1L-2L yellow, 2L+ red)
- Lighting: Low-key, dramatic, single key light, deep shadows
- Text: TOP '🚨 DROP OR JOIN?'. MIDDLE 'BRUTAL TRUTH'. BOTTOM 'YOUR RANK, YOUR LIFE'
- Background voices: Heavy breathing, faint "kya karu..." whispers""",
            2: """DECISION MATRIX - DATA-DRIVEN
- Character: ANALYTICAL - pointing at data, calm, logical gestures
- Background: Interactive matrix - rank vs ROI vs risk, animated bars
- Lighting: Cool blue (data vibe), clean
- Text: '50K-1L: DROP VIABLE', '1L-2L: HIGH RISK', '2L+: COLLEGE BETTER ROI'
- Background voices: Calculator clicks, data 'ping'""",
            3: """ROI REALITY CHECK - HARD NUMBERS
- Character: SERIOUS/REALISTIC - hands spread 'weighing', somber expression
- Background: Split - Drop year costs (time, money, mental) vs College placement data
- Lighting: Balanced, slightly warm on college side, cool on drop side
- Text: 'DROP: 12 MONTHS + FEES + PRESSURE', 'SKILLS > BRAND', 'MIDDLE PATH EXISTS'
- Background voices: Coin drop sounds, cash register""",
            4: """CTA - DECIDE TODAY
- Character: URGENT BROTHER - pointing at viewer, intense eye contact, 'now' gesture
- Background: Calendar with counseling deadline RED CIRCLE
- Lighting: Urgent red rim, warm key on face
- Text: 'DEADLINE: AUG 18-20', 'DECIDE TODAY', CTA animated
- Background voices: Clock ticking fast, final heartbeat"""
        }
        return guidance.get(clip_index, "Standard clip")

    def _counseling_guidance(self, clip_index: int) -> str:
        guidance = {
            1: """HOOK - DEADLINE URGENCY
- Character: URGENT ALERT - wide eyes, raised eyebrows, hand to ear 'listen', lean in
- Background: Red alert style, multiple countdown timers (CSAB, IPU, JAC)
- Lighting: Emergency red key, flashing practicals
- Text: TOP '🚨 DEADLINES THIS WEEK', MIDDLE 'CSAB SPECIAL + IPU SPOT', BOTTOM 'AUG 18-20'
- Background voices: Alarm sirens faint, student panic whispers""",
            2: """KEY DATES & PROCESS - CLEAR INFO
- Character: INFORMATIVE/ORGANIZED - finger counting dates, checklist gesture
- Background: Calendar with dates highlighted, process flowchart
- Lighting: Clean, professional
- Text: Each date + action item animated in
- Background voices: Calendar 'thud', pen check sounds""",
            3: """DOCUMENT CHECKLIST - PRACTICAL
- Character: HELPFUL/THOROUGH - checking off invisible list, nodding each item
- Background: Document stack, each doc slides in with green check
- Lighting: Warm, reassuring
- Text: 'DOC 1 ✓', 'DOC 2 ✓', 'COMMON MISTAKES ✗'
- Background voices: Paper shuffle, stamp 'approved'""",
            4: """CTA - YOUR STATE, YOUR ACTION
- Character: DIRECT CALL TO ACTION - pointing down 'comment', urgent but caring
- Background: Map of India with state highlights
- Lighting: Warm key, cool rim
- Text: 'COMMENT YOUR STATE', 'GET STATE-SPECIFIC INFO', CTA
- Background voices: Map 'ping' each state, final bell"""
        }
        return guidance.get(clip_index, "Standard clip")

    def _generic_guidance(self, clip_index: int) -> str:
        guidance = {
            1: "HOOK - URGENT OPENING with character: SHOCKED/URGENT, background: RED GRADIENT, text: MAIN HOOK",
            2: "CONTENT - ENERGETIC EXPLANATION with character: CONFIDENT/TEACHING, background: SPLIT SCREEN, text: KEY POINTS",
            3: "STRATEGY - PRACTICAL DEMO with character: FOCUSED/STRUCTURED, background: SCREEN/WHITEBOARD, text: STEPS",
            4: "CTA - EMOTIONAL PUSH with character: BROTHERLY/ENCOURAGING, background: WARM GRADIENT, text: GENERIC CTA"
        }
        return guidance.get(clip_index, "Standard clip")

    def _get_clip_guidance_for_structure(self, plan: ContentPlan, clip_index: int, segment: str, clip_info: Dict) -> str:
        """Return clip-specific creative guidance based on autonomous structure decision."""
        focus = clip_info.get('focus', '').lower()
        section = clip_info.get('section', '').lower()
        
        # Check if this is a hook clip (first clip or contains hook)
        is_hook = clip_index == 1 or 'hook' in section or 'hook' in focus
        # Check if this is CTA clip (last clip or contains CTA)
        is_cta = clip_index == len(plan.structure_outline) or 'cta' in section or 'cta' in focus
        
        if "mock" in plan.topic.lower():
            return self._mock_strategy_guidance_for_structure(clip_index, is_hook, is_cta, focus)
        elif "backlog" in plan.topic.lower():
            return self._backlog_guidance_for_structure(clip_index, is_hook, is_cta, focus)
        elif "11th" in plan.topic.lower() or "20 month" in plan.topic.lower():
            return self._11th_grade_guidance_for_structure(clip_index, is_hook, is_cta, focus)
        elif "drop" in plan.topic.lower() or "lower college" in plan.topic.lower():
            return self._drop_vs_college_guidance_for_structure(clip_index, is_hook, is_cta, focus)
        elif any(k in plan.topic.lower() for k in ["counsel", "spot", "round", "csab", "ipu", "jac"]):
            return self._counseling_guidance_for_structure(clip_index, is_hook, is_cta, focus)
        else:
            # Generic guidance based on clip position and focus
            if is_hook:
                return """HOOK - URGENT OPENING
- Character: SHOCKED/URGENT - eyes wide, eyebrows high, mouth slightly open, lean forward aggressively
- Background: Deep red → black gradient, pulsing alarm light, digital countdown
- Lighting: Harsh top-down key (interrogation style), cool blue rim, dramatic shadows
- Text: TOP '🚨 LAST CHANCE' large red outline pulse. MIDDLE main hook text. BOTTOM urgency indicator.
- Background voices: FAINT panicked student voices overlapping
- SFX: Heartbeat (fast), emergency alert beep"""
            elif is_cta:
                return """CTA - EMOTIONAL PUSH
- Character: ENCOURAGING/BROTHERLY - warm smile, slight nod, hand on heart, direct eye contact
- Background: Warm gradient (orange → gold), subtle particles rising, progress indicator
- Lighting: Golden hour warm key, soft fill, rim light halo effect
- Text: TOP 'EVERY ACTION COUNTS'. MIDDLE Hindi+English encouragement. BOTTOM CTA animated typewriter
- Background voices: Faint cheering, notification sounds, final heartbeat slow and steady
- SFX: Subscribe bell 'ding', final heartbeat thump"""
            elif clip_index == 2:
                return """CORE CONTENT - MYTH BUSTING / KEY INSIGHTS
- Character: ENERGETIC/MYTH-BUSTER - confident, gestures for emphasis, pointing at invisible cards
- Background: Split screen or visual contrast - OLD WAY vs NEW WAY
- Lighting: High-key, bright, energetic - key light front, fill light soft
- Text: TOP 'MYTH vs REALITY' or key framework. Columns with animated checks/crosses
- Background voices: Each point = sound effect + whisper reaction
- SFX: Pop for myths, chime for reality"""
            elif clip_index == 3:
                return """PRACTICAL STRATEGY - HOW-TO / ACTIONABLE STEPS
- Character: PRACTICAL/FOCUSED - calm, nodding, finger counting steps, pointing at screen
- Background: Screen recording demo, whiteboard, or visual process flow
- Lighting: Cool blue key (tech/professional vibe), warm rim on face
- Text: STEP-BY-STEP overlay animated in sync: '1. STEP ONE', '2. STEP TWO', etc.
- Background voices: Keyboard clicks, mouse clicks, subtle ambient sounds
- SFX: 'Whoosh' on each step, 'Ding!' on completion"""
            else:
                return "Standard clip - follow general rules"

    def _mock_strategy_guidance_for_structure(self, clip_index: int, is_hook: bool, is_cta: bool, focus: str) -> str:
        if is_hook:
            return """HOOK - SHOCK THEM INTO ACTION
- Character: SHOCKED/URGENT - eyes wide, eyebrows high, mouth slightly open, lean forward aggressively
- Background: Deep red → black gradient, pulsing alarm light, digital countdown "5:00:00:00" (months:days:hours:mins)
- Lighting: Harsh top-down key (interrogation style), cool blue rim, dramatic shadows
- Text: TOP '🚨 LAST CHANCE' large red outline pulse. MIDDLE 'MOCKS = DIAGNOSTIC TOOL' white. BOTTOM '5 MONTHS' yellow.
- Background voices: FAINT panicked student voices "syllabus nahi hua... kaise mock...?" overlapping
- SFX: Heartbeat (fast), emergency alert beep every 3s"""
        elif is_cta:
            return """CTA - EVERY MOCK COUNTS - EMOTIONAL PUSH
- Character: ENCOURAGING/BROTHERLY - warm genuine smile, slight nod, hand on heart, direct locked eye contact, lean back relaxed but urgent
- Background: Warm gradient (orange → gold), subtle particles rising, progress bar filling "MOCK 1 → MOCK 30"
- Lighting: Golden hour warm key, soft fill, rim light halo effect
- Text: TOP 'EVERY MOCK COUNTS' bold white with gold outline. MIDDLE 'HAR MOCK MATTER KARTA HAI' Hindi + English. BOTTOM CTA animated typewriter: 'LIKE • SHARE • SUBSCRIBE • COMMENT YOUR DOUBTS'
- Background voices: Faint cheering "Go! Go!", notification sounds "ping ping", final heartbeat slow and steady
- SFX: Subscribe bell 'ding', final heartbeat thump"""
        elif clip_index == 2:
            return """WHY MOCKS MATTER - MYTH BUSTING WITH ENERGY
- Character: ENERGETIC/MYTH-BUSTER - eyebrows furrowed, confident smirk, chopping hand gestures, pointing at invisible myths
- Background: Split screen - LEFT: "OLD WAY" (student buried in books, gray), RIGHT: "MOCK FIRST" (student confident, green checkmarks)
- Lighting: High-key, bright, energetic - key light front, fill light soft, warm practicals
- Text: TOP 'MYTH vs REALITY'. LEFT column: 'Syllabus first ✗', '90% score ✗', 'More mocks ✗'. RIGHT: 'Gaps first ✓', 'Any score ✓', 'Analysis ✓'
- Background voices: Each myth busted → "POP!" sound + whisper "bakwaas!"
- SFX: Myth bust = balloon pop, Reality = cash register 'cha-ching'"""
        elif clip_index == 3:
            return """HOW TO ATTEMPT - PRACTICAL DEMO MODE
- Character: PRACTICAL/FOCUSED - calm, nodding, finger counting steps, screen-pointing gesture
- Background: Screen recording of mock test interface (timer top-right, question palette left), avatar picture-in-picture bottom-right
- Lighting: Cool blue key (tech vibe), warm rim on face, screen glow on face
- Text: STEP-BY-STEP overlay as he speaks: '1. SET TIMER', '2. FULL PAPER', '3. MARK GUESSES', '4. TIME/SECTION'
- Background voices: Keyboard clicks, mouse clicks, timer tick-tock (subtle)
- SFX: 'Whoosh' on each step, 'Ding!' on completion"""
        else:
            return """POST-MOCK ANALYSIS - MISTAKE CATEGORIZATION
- Character: ANALYTICAL/EMPATHETIC - calm, nodding, pointing at analysis categories
- Background: Mock analysis interface - wrong answers categorized: Concept/Silly/Time
- Lighting: Cool analytical, warm rim
- Text: 'CONCEPT GAP ✓', 'SILLY MISTAKE ✗', 'TIME PRESSURE ⏱', 'WEAK TOPIC LIST →'
- Background voices: Pen scratch, checkmark 'tick', realization 'ahaan...'
- SFX: Category 'pop', insight 'ding'"""

    def _build_metadata_prompt(self, plan: ContentPlan, clips: List[ClipScript]) -> str:
        """Build prompt for title, description, tags, thumbnail generation."""
        clips_summary = "\n".join([f"Clip {c.clip_index}: {c.voiceover_text[:60]}..." for c in clips])
        return f"""Based on the full video context and these 4 clips:
{clips_summary}

Generate metadata as JSON:
{{
  "title": "Catchy YouTube Shorts title with 🚨, <60 chars, includes JEE Main 2027/2028",
  "description": "2-3 sentence description with hooks, keywords, and CTA",
  "tags": ["JEE", "JEEMain2027", "MockTest", "Strategy", "Preparation"],
  "thumbnail_concept": "HIGH CONTRAST <5 WORDS for last 1s overlay (e.g., 'START MOCKS NOW')"
}}

Rules:
- Title must have 🚨 and target exam
- Description must include urgency + value prop
- Tags: 5 max, relevant
- Thumbnail concept: action-oriented, <5 words, ALL CAPS
"""

    def _parse_clip_response(self, content: str, clip_index: int) -> Optional[Dict]:
        """Parse clip JSON from LLM response."""
        try:
            # Extract JSON from markdown if present
            json_match = re.search(r'\{.*\}', content, re.DOTALL)
            if json_match:
                data = json.loads(json_match.group())
            else:
                data = json.loads(content)
            
            # Validate required fields
            required = ["flow_prompt", "voiceover_text", "visual_cues", "transition_note"]
            if all(k in data for k in required):
                return data
        except Exception as e:
            print(f"[SCRIPT_WRITER] Clip {clip_index} parse error: {e}")
        return None

    def _parse_metadata_response(self, content: str) -> Dict:
        """Parse metadata JSON from LLM response."""
        try:
            json_match = re.search(r'\{.*\}', content, re.DOTALL)
            if json_match:
                return json.loads(json_match.group())
        except Exception as e:
            print(f"[SCRIPT_WRITER] Metadata parse error: {e}")
        return {
            "title": "🚨 JEE Strategy - Start NOW",
            "description": "Actionable JEE strategy. Like, share, subscribe, comment!",
            "tags": ["JEE", "Preparation", "Strategy"],
            "thumbnail_concept": "TAKE ACTION NOW"
        }

    def _detect_segment(self, plan: ContentPlan) -> str:
        """Detect which audience segment this plan targets."""
        topic_lower = plan.topic.lower()
        if "mock" in topic_lower:
            return "mock_strategy"
        elif "backlog" in topic_lower:
            return "backlog_clearance"
        elif "11th" in topic_lower or "20 month" in topic_lower:
            return "11th_grade"
        elif "drop" in topic_lower or "lower college" in topic_lower:
            return "drop_vs_college"
        elif any(k in topic_lower for k in ["counsel", "spot", "round", "csab", "ipu", "jac"]):
            return "counseling"
        return "generic"

    # Keep existing fallback methods unchanged
    def _fallback_script(self, run: PipelineRun, plan: ContentPlan) -> VideoScript:
        """Generate topic-aware fallback script."""
        topic_lower = plan.topic.lower()
        is_mock_strategy = "mock" in topic_lower
        is_drop_vs_college = any(k in topic_lower for k in ["drop", "lower college", "worth it"])
        is_backlog = any(k in topic_lower for k in ["backlog", "clearance"])
        is_11th = plan.topic.lower().find("11th") != -1 or "20 month" in topic_lower
        is_counseling = any(k in topic_lower for k in ["counsel", "spot", "round", "csab", "ipu", "jac"])

        if is_mock_strategy:
            return self._mock_strategy_fallback(plan)
        elif is_drop_vs_college:
            return self._drop_vs_college_fallback(plan)
        elif is_backlog:
            return self._backlog_fallback(plan)
        elif is_11th:
            return self._11th_grade_fallback(plan)
        elif is_counseling:
            return self._counseling_fallback(plan)
        else:
            return self._generic_fallback(plan)

    def _mock_strategy_fallback(self, plan: ContentPlan) -> VideoScript:
        clips = [
            ClipScript(
                clip_index=1,
                duration_seconds=15,
                flow_prompt="Talking head, extreme close-up, camera slowly pushes in. AI Avatar: URGENT mood, eyebrows furrowed, eyes wide locked on lens, leaning forward 15°, right hand chops air for emphasis. Background: Deep red gradient (#8B0000 to #000000), subtle pulsing alarm light top-right. Lighting: Hard key light camera-left at 45°, cool rim light camera-right, dramatic low-key. Text overlay TOP: '🚨 LAST CHANCE' bold white with red outline, pulse animation. Text overlay BOTTOM: '5 MONTHS LEFT' yellow bold. SFX: Slow heartbeat thump-thump under voiceover. Background voices: Faint distant student murmurs 'bhaiya... bhaiya...' barely audible. Voiceover: 'Bhaiya, 5 mahine bache hain JEE Main 2027 ke! Mocks abhi se shuru karo!' Transition: Hard cut to medium shot on 'abhi se'.",
                voiceover_text="Bhaiya, 5 mahine bache hain JEE Main 2027 ke! Mocks abhi se shuru karo!",
                visual_cues=["🚨 LAST CHANCE", "5 MONTHS LEFT", "JEE Main 2027", "HEARTBEAT SFX"],
                transition_note="Hard cut on 'abhi se' to medium shot"
            ),
            ClipScript(
                clip_index=2,
                duration_seconds=15,
                flow_prompt="Talking head, medium shot, slight low angle (hero shot). Character: ENERGETIC MYTH-BUSTER, confident smirk, eyebrows furrowed in determination, chopping hand gestures for each myth, pointing at invisible cards. Background: Split screen vertical - LEFT dark gray 'OLD WAY' student buried in books, RIGHT bright green 'MOCK FIRST' student with checkmarks floating. Lighting: High-key bright, key light front and center, warm practical desk lamps both sides, energetic vibe. Text overlay TOP: 'MYTH vs REALITY' bold. LEFT column animated red X: 'Syllabus first ✗', '90% score ✗', 'More mocks ✗'. RIGHT column animated green check: 'Gaps first ✓', 'Any score ✓', 'Analysis ✓'. Background voices: Each myth = 'POP!' balloon burst + whisper 'bakwaas!'. Reality = 'CHA-CHING!' cash register. SFX: Whoosh between myths. Voiceover: 'Syllabus complete hone ka wait mat karo. Mocks diagnose gaps, build temperament, guide study plan.' Transition: Whip pan right to screen recording demo.",
                voiceover_text="Syllabus complete hone ka wait mat karo. Mocks diagnose gaps, build temperament, guide study plan.",
                visual_cues=["MYTH vs REALITY", "SYLLABUS FIRST ✗", "GAPS FIRST ✓", "ANALYSIS ✓"],
                transition_note="Whip pan to screen recording demo"
            ),
            ClipScript(
                clip_index=3,
                duration_seconds=15,
                flow_prompt="Screen recording demo + talking head picture-in-picture bottom-right. Character (PiP): PRACTICAL FOCUSED, calm nodding, finger counting steps 1-2-3-4, pointing at screen. Background: Full-screen mock test interface - timer top-right counting down 3:00:00, question palette left with colored dots, current question center. Lighting: Cool blue key light (tech aesthetic), screen glow illuminates face, warm rim light separates from background. Text overlay STEPS animated in sync: '1. SET TIMER 3 HOURS', '2. ATTEMPT FULL PAPER', '3. MARK GUESSES ⭐', '4. NOTE TIME PER SECTION'. Graphics: Progress bar filling, section timer pie charts. Background voices: Mechanical keyboard clicks, mouse click 'click', subtle timer tick-tock. SFX: 'WHOOSH' each step appears, 'DING!' on step complete. Voiceover: 'Timer set karo, full paper attempt karo, guesses mark karo, time per section note karo.' Transition: Match cut timer → analysis screen.",
                voiceover_text="Timer set karo, full paper attempt karo, guesses mark karo, time per section note karo.",
                visual_cues=["SET TIMER", "ATTEMPT FULL PAPER", "MARK GUESSES", "TIME PER SECTION"],
                transition_note="Match cut timer to analysis"
            ),
            ClipScript(
                clip_index=4,
                duration_seconds=15,
                flow_prompt="Talking head, close-up, warm intimate framing. Character: ENCOURAGING BHAIYA, warm genuine smile, slight nod, right hand over heart, direct locked eye contact, lean back relaxed but leaning in on key words. Background: Warm golden gradient (orange #FF8C00 to gold #FFD700), subtle golden particles rising upward, progress bar 'MOCK 1 → MOCK 30' filling smoothly. Lighting: Golden hour warm key light, soft fill, beautiful rim light halo on hair/shoulders, inviting. Text overlay TOP: 'EVERY MOCK COUNTS' bold white with gold outline. MIDDLE animated: 'HAR MOCK MATTER KARTA HAI' Hindi + English. BOTTOM CTA animated typewriter: 'LIKE • SHARE • SUBSCRIBE • COMMENT YOUR DOUBTS'. Background voices: Faint rising cheer 'Go! Go! Go!', notification 'ping ping', final slow steady heartbeat 'thump... thump...'. SFX: Subscribe bell 'DING!', final heartbeat. Voiceover: 'Like, share, subscribe, comment your mock test doubts! Har mock matter karta hai, aaj se shuru karo!' Transition: End screen with thumbnail overlay 'START MOCKS NOW'.",
                voiceover_text="Like, share, subscribe, comment your mock test doubts! Har mock matter karta hai, aaj se shuru karo!",
                visual_cues=["EVERY MOCK COUNTS", "LIKE • SHARE • SUBSCRIBE", "COMMENT YOUR DOUBTS", "PROGRESS BAR"],
                transition_note="End screen with thumbnail overlay"
            )
        ]
        return VideoScript(
            topic=plan.topic,
            title="🚨 You Should Do This NOW: Mock Test Strategy for JEE Main 2027",
            description="Mock tests are NOT for after syllabus. They're your diagnostic tool from Day 1. Learn the exact strategy to attempt, analyze, and improve with every mock. 5 months to JEE Main 2027 - start TODAY!",
            tags=["JEE", "JEEMain2027", "MockTest", "Strategy", "Preparation"],
            clips=clips,
            thumbnail_concept="START MOCKS NOW",
            google_flow_context_prompt=self._build_google_flow_context_prompt(plan)
        )

    def _drop_vs_college_fallback(self, plan: ContentPlan) -> VideoScript:
        clips = [
            ClipScript(
                clip_index=1,
                duration_seconds=15,
                flow_prompt="Talking head, extreme close-up, static camera. Character: SERIOUS TOUGH LOVE, steady unblinking gaze, slow deliberate head shake, palm down 'stop' gesture, lean forward intense. Background: Dark gradient (#1a0000 to #000000), three horizontal rank bands glowing: TOP green '50K-1L', MIDDLE yellow '1L-2L', BOTTOM red '2L+'. Lighting: Single hard key light camera-left (interrogation), deep shadows, cool blue rim barely visible. Text TOP: '🚨 DROP OR JOIN?' large red with white outline. MIDDLE: 'BRUTAL TRUTH' white. BOTTOM: 'YOUR RANK, YOUR LIFE' yellow. Background voices: Heavy breathing, faint desperate whispers 'kya karu... bhaiya...'. SFX: Low ominous drone, slow heavy heartbeat. Voiceover: 'Bhaiya, low rank aaya hai. Drop le ya lower college join kar? Brutal truth sunlo!' Transition: Hard cut to data matrix.",
                voiceover_text="Bhaiya, low rank aaya hai. Drop le ya lower college join kar? Brutal truth sunlo!",
                visual_cues=["🚨 DROP OR JOIN?", "BRUTAL TRUTH", "RANK BANDS", "YOUR LIFE"],
                transition_note="Hard cut to decision matrix"
            ),
            ClipScript(
                clip_index=2,
                duration_seconds=15,
                flow_prompt="Talking head + interactive data matrix overlay. Character: ANALYTICAL LOGICAL, calm posture, finger tracing matrix columns, pointing at data bars. Background: Clean dark, animated 3-column matrix: RANK BAND | DROP VIABILITY | ROI SCORE | RISK LEVEL. Rows light up as spoken. Lighting: Cool blue key (data center vibe), clean rim, high contrast on matrix. Text: Matrix cells populate: '50K-1L | HIGH | 85% | LOW', '1L-2L | MEDIUM | 55% | HIGH', '2L+ | LOW | 30% | VERY HIGH'. Background voices: Calculator clicks, data 'PING' each cell. SFX: 'WHOOSH' row reveal. Voiceover: 'Rank band dekho: 50k se 1 lakh drop viable, 1 se 2 lakh risk high, 2 lakh plus college better ROI.' Transition: Dissolve to ROI comparison.",
                voiceover_text="Rank band dekho: 50k se 1 lakh drop viable, 1 se 2 lakh risk high, 2 lakh plus college better ROI.",
                visual_cues=["DECISION MATRIX", "50K-1L: VIABLE", "1L-2L: RISK", "2L+: COLLEGE"],
                transition_note="Dissolve to ROI reality"
            ),
            ClipScript(
                clip_index=3,
                duration_seconds=15,
                flow_prompt="Talking head, medium shot, split background. Character: REALISTIC SOMBER, hands spread weighing scales gesture, somber expression, slow blink. Background: LEFT side cool blue 'DROP YEAR' - calendar 12 pages tearing off, ₹ symbol burning, brain with stress lines. RIGHT side warm gold 'COLLEGE' - placement stats rising, skill icons glowing, certificate. Lighting: Split - cool on left, warm on right, rim light bridges both. Text: LEFT '12 MONTHS + FEES + MENTAL PRESSURE', RIGHT 'PLACEMENT DATA', CENTER 'SKILLS > BRAND', BOTTOM 'MIDDLE PATH EXISTS'. Background voices: Coin drops 'clink', paper tear 'rip', cash register 'cha-ching'. SFX: Scale tip sound. Voiceover: 'Drop year cost: 12 months plus fees plus mental pressure. College placement data compare karo. Skills brand se zyada matter karte hain.' Transition: Zoom into calendar deadline.",
                voiceover_text="Drop year cost: 12 months plus fees plus mental pressure. College placement data compare karo. Skills brand se zyada matter karte hain.",
                visual_cues=["DROP COST", "PLACEMENT DATA", "SKILLS > BRAND", "MIDDLE PATH"],
                transition_note="Zoom to deadline calendar"
            ),
            ClipScript(
                clip_index=4,
                duration_seconds=15,
                flow_prompt="Talking head, close-up, urgent framing. Character: URGENT BROTHER, intense locked eye contact, index finger pointing directly at lens/viewer, 'NOW' chop gesture, slight forward lean. Background: Calendar pages flipping fast to AUGUST, red circles on 18, 19, 20 - 'CSAB SPECIAL ROUND', 'IPU SPOT ROUND 2', 'JAC SPOT'. Lighting: Urgent red rim light pulsing, warm key on face, dramatic. Text: TOP 'DEADLINE: AUG 18-20' red pulsing. MIDDLE 'DECIDE TODAY' large white. BOTTOM CTA animated: 'LIKE • SHARE • SUBSCRIBE • COMMENT RANK & DILEMMA'. Background voices: Fast clock ticking 'tick-tick-tick', final slow heartbeat. SFX: Alarm beep, subscribe bell. Voiceover: 'Like, share, subscribe, comment your rank and dilemma! Counseling ending soon - decide TODAY!' Transition: End screen 'DROP OR JOIN?' thumbnail.",
                voiceover_text="Like, share, subscribe, comment your rank and dilemma! Counseling ending soon - decide TODAY!",
                visual_cues=["DECIDE TODAY", "AUG 18-20", "LIKE • SHARE • SUBSCRIBE", "COMMENT RANK"],
                transition_note="End screen with thumbnail"
            )
        ]
        return VideoScript(
            topic=plan.topic,
            title="🚨 Low JEE Score: Drop Year or Join Lower College? Brutal Truth",
            description="The dilemma every low-rank aspirant faces. Data-driven decision matrix, ROI reality check, and personal checklist. No generic advice - YOUR rank, YOUR decision.",
            tags=["JEE", "DropYear", "CollegeDecision", "Counseling2026", "CareerGuidance"],
            clips=clips,
            thumbnail_concept="DROP OR JOIN?",
            google_flow_context_prompt=self._build_google_flow_context_prompt(plan)
        )

    def _backlog_fallback(self, plan: ContentPlan) -> VideoScript:
        clips = [
            ClipScript(
                clip_index=1,
                duration_seconds=15,
                flow_prompt="Talking head, medium-close, empathetic but firm. Character: EMPATHETIC BROTHER, slight frown understanding, nodding 'I get it', hand up 'stop panic', lean forward caring. Background: Split screen - LEFT chaotic calendar red X marks 'BACKLOG', RIGHT clean green '70/30 PLAN' with weekly boxes. Lighting: Neutral balanced, practical desk lamp visible warm glow. Text TOP: '🚨 5 MONTHS LEFT' red pulse. MIDDLE animated: '11TH BACKLOG + 12TH = ?' → '70/30 STRATEGY' green. BOTTOM: 'MOCK FIRST APPROACH'. Background voices: Student stressed sigh 'bahut hai...', mentor whisper 'shhh, sun...'. SFX: Calendar flip, pen click. Voiceover: 'Bhaiya, 11th backlog hai, 12th bhi karna hai. 5 mahine me kaise manage karein?' Transition: Whip pan to myth cards.",
                voiceover_text="Bhaiya, 11th backlog hai, 12th bhi karna hai. 5 mahine me kaise manage karein?",
                visual_cues=["🚨 5 MONTHS LEFT", "70/30 STRATEGY", "MOCK FIRST", "BACKLOG + 12TH"],
                transition_note="Whip pan to myth busting"
            ),
            ClipScript(
                clip_index=2,
                duration_seconds=15,
                flow_prompt="Talking head + animated myth cards flipping. Character: DIRECT AUTHORITATIVE, finger wag 'NO', palm up 'STOP', confident posture, each myth = card flip. Background: Dark, three large cards float and flip 3D: CARD 1 '100% SYLLABUS FIRST' red → flip → 'MOCK FIRST' green. CARD 2 'NCERT KAAFI HAI' red → 'ADVANCED NEEDED' green. CARD 3 '14 GHANTE PADHO' red → 'CONSISTENCY > INTENSITY' green. Lighting: High contrast dramatic - red rim on myth side, green rim on reality side. Text: Each card shows both sides animated. Background voices: Each flip = 'THWIP' card sound, whisper 'galat tha...'. SFX: Card flip, success chime on green. Voiceover: 'Myth 1: 100 percent syllabus chahiye mocks se pehle. Myth 2: NCERT kaafi hai. Myth 3: 14 ghante padho. Sab bakwaas!' Transition: Draw 70/30 on whiteboard.",
                voiceover_text="Myth 1: 100 percent syllabus chahiye mocks se pehle. Myth 2: NCERT kaafi hai. Myth 3: 14 ghante padho. Sab bakwaas!",
                visual_cues=["NO 100% SYLLABUS", "NCERT NOT ENOUGH", "NO 14 HOURS", "MOCK FIRST"],
                transition_note="Whiteboard 70/30 strategy"
            ),
            ClipScript(
                clip_index=3,
                duration_seconds=15,
                flow_prompt="Talking head + whiteboard drawing (simulated). Character: STRUCTURED TEACHER, drawing pie chart 70/30, pointing at sections, explaining with hands, marker in hand. Background: Whiteboard with large 70/30 pie chart, '12TH CURRENT TOPICS' 70%, '11TH HIGH-YIELD' 30%, arrow 'MOCK → GAPS → STUDY', weekly mini-calendar Mon-Sun. Lighting: Cool white classroom style, key on board, warm rim on face. Text: '70% = 12TH CURRENT', '30% = TARGETED 11TH', 'HIGH-YIELD CHAPTERS', 'MOCK-FIRST LEARNING'. Background voices: Marker squeak 'squeak', chalk 'tap-tap', student realization 'ahaan...'. SFX: Drawing sounds, 'DING' insight. Voiceover: '70 percent 12th current topics, 30 percent targeted 11th high-yield. Mocks se gaps pata chalte hain, phir wahi padho.' Transition: Calendar weekly plan.",
                voiceover_text="70 percent 12th current topics, 30 percent targeted 11th high-yield. Mocks se gaps pata chalte hain, phir wahi padho.",
                visual_cues=["70% 12TH", "30% 11TH HIGH-YIELD", "MOCK FIRST", "WEEKLY PLAN"],
                transition_note="Weekly calendar plan"
            ),
            ClipScript(
                clip_index=4,
                duration_seconds=15,
                flow_prompt="Talking head, close-up, action-oriented. Character: MOTIVATIONAL BROTHER, finger guns 'you got this', thumbs up, confident warm smile, direct eye contact. Background: Weekly calendar Mon-Sun boxes filling with color codes: MON-WED blue '12TH', THU orange '11TH BACKLOG', FRI red 'MOCK', SAT green 'ANALYSIS', SUN purple 'WEAK TOPICS'. Lighting: Warm encouraging golden key, soft fill, halo rim. Text: Each day animates in with color: 'MON-WED: 12TH NEW', 'THU: 11TH BACKLOG', 'FRI: MOCK', 'SAT: ANALYSIS', 'SUN: WEAK TOPICS'. BOTTOM: 'CONSISTENCY > INTENSITY'. BOTTOM CTA: 'LIKE • SHARE • SUBSCRIBE • COMMENT TARGET COLLEGE'. Background voices: Each day 'THUD' stamp, final cheer 'YES!'. SFX: Stamp, subscribe bell. Voiceover: 'Like, share, subscribe, comment your target college! Backlog clear karo, mocks shuru karo - aaj se!' Transition: End screen 'BACKLOG CLEARED'.",
                voiceover_text="Like, share, subscribe, comment your target college! Backlog clear karo, mocks shuru karo - aaj se!",
                visual_cues=["START TODAY", "WEEKLY PLAN", "LIKE • SHARE • SUBSCRIBE", "TARGET COLLEGE"],
                transition_note="End screen with thumbnail"
            )
        ]
        return VideoScript(
            topic=plan.topic,
            title="🚨 11th Backlog + JEE 2027: 5-Month Strategy That Actually Works",
            description="Overwhelmed by 11th backlog and 12th syllabus? 70/30 split strategy, mock-first approach, realistic weekly plan. No impossible timetables - just what works in 5 months.",
            tags=["JEE", "JEEMain2027", "BacklogClearance", "11thBacklog", "Strategy"],
            clips=clips,
            thumbnail_concept="BACKLOG CLEARED",
            google_flow_context_prompt=self._build_google_flow_context_prompt(plan)
        )

    def _11th_grade_fallback(self, plan: ContentPlan) -> VideoScript:
        clips = [
            ClipScript(
                clip_index=1,
                duration_seconds=15,
                flow_prompt="Talking head, medium shot, warm welcoming. Character: ENCOURAGING BIG BROTHER, warm genuine smile, slight head tilt 'welcome', open palm gesture 'come', relaxed but urgent energy. Background: Bright optimistic gradient (teal #008080 to blue #0000FF), large '20 MONTHS' counter center, calendar pages flipping forward fast showing months 1-20. Lighting: High-key bright optimistic, warm key, soft fill, no harsh shadows. Text TOP: '🚨 20 MONTHS' large friendly. MIDDLE: 'START RIGHT, NOT FAST' animated typewriter. BOTTOM: 'JEE 2028' subtle. Background voices: Excited student whispers '20 mahine? Kaafi hain!', 'Start right not fast...'. SFX: Calendar flip forward 'flap-flap', positive chime. Voiceover: 'Bhaiya, 11th me ho? 20 mahine hain JEE 2028 ke. Start right, not fast - ye video dekhlo!' Transition: Smooth zoom to myth bubbles.",
                voiceover_text="Bhaiya, 11th me ho? 20 mahine hain JEE 2028 ke. Start right, not fast - ye video dekhlo!",
                visual_cues=["🚨 20 MONTHS", "JEE 2028", "START RIGHT NOT FAST", "20 MONTHS = TIME"],
                transition_note="Smooth zoom to myths"
            ),
            ClipScript(
                clip_index=2,
                duration_seconds=15,
                flow_prompt="Talking head + floating myth bubbles popping. Character: CALM KNOWING, slight amused smile, finger counting myths 1-2-3, relaxed posture, each myth = bubble pop. Background: Clean bright, three large soap bubbles float: BUBBLE 1 'ADVANCED PROBLEMS ABHI SE' → POP → 'FOUNDATION FIRST'. BUBBLE 2 'COACHING MANDATORY DAY 1' → POP → 'SELF STUDY WORKS'. BUBBLE 3 'NCERT BASIC HAI' → POP → 'NCERT IS FOUNDATION'. Lighting: Soft even friendly, warm key, gentle rim. Text: Each bubble shows myth → pop → reality in clean font. Background voices: Bubble pop 'POP', whisper 'sahi hai...', 'pata nahi tha...'. SFX: Bubble pop, magic sparkle on reality. Voiceover: 'Myth: Advanced problems abhi se karo. Myth: Coaching mandatory day 1. Myth: NCERT basic hai. Reality: Foundation first!' Transition: Sweep hand to timeline.",
                voiceover_text="Myth: Advanced problems abhi se karo. Myth: Coaching mandatory day 1. Myth: NCERT basic hai. Reality: Foundation first!",
                visual_cues=["NO ADVANCED YET", "COACHING NOT MANDATORY", "NCERT IS FOUNDATION", "20 MONTHS = TIME"],
                transition_note="Sweep to 20-month roadmap"
            ),
            ClipScript(
                clip_index=3,
                duration_seconds=15,
                flow_prompt="Talking head + horizontal timeline visualization. Character: VISIONARY STRUCTURED, sweeping hand left-to-right across timeline phases, pointing at each, confident posture. Background: Clean horizontal timeline 3 phases: PHASE 1 (months 1-6) 'NCERT + BASICS' blue icons, PHASE 2 (months 7-14) 'PRACTICE + CONCEPTS' green icons, PHASE 3 (months 15-20) 'MOCKS + REVISION' orange icons. School+JEE integration icons bridging all phases (school building + JEE logo connected). Lighting: Professional cool key, warm rim, clean separation. Text: Phase labels animate in: 'PHASE 1: 6M NCERT', 'PHASE 2: 8M PRACTICE', 'PHASE 3: 6M MOCKS', 'SCHOOL + JEE INTEGRATED' bridge. Background voices: Timeline 'WHOOSH' each phase, student 'clear hai...'. SFX: Phase transition 'whoosh', bridge 'click'. Voiceover: 'Phase 1: 6 months NCERT basics. Phase 2: 8 months practice concepts. Phase 3: 6 months mocks revision. School integrate karo, separate mat karo!' Transition: Daily habit tracker.",
                voiceover_text="Phase 1: 6 months NCERT basics. Phase 2: 8 months practice concepts. Phase 3: 6 months mocks revision. School integrate karo, separate mat karo!",
                visual_cues=["PHASE 1: NCERT", "PHASE 2: PRACTICE", "PHASE 3: MOCKS", "SCHOOL+JEE INTEGRATED"],
                transition_note="Daily habits & CTA"
            ),
            ClipScript(
                clip_index=4,
                duration_seconds=15,
                flow_prompt="Talking head, close-up intimate brotherly. Character: BROTHERLY PUSH, warm eye contact, implied hand on shoulder (chest level gesture), sincere nod, 'you can do this' energy. Background: Daily habit tracker filling - MORNING sun icon 'CONCEPTS', EVENING moon icon 'REVISION', WEEKEND calendar 'MOCK'. Warm gold particles. Lighting: Golden hour intimate, warm key, beautiful rim halo, inviting. Text: '2-3 HOURS DAILY', 'MORNING: CONCEPTS', 'EVENING: REVISION', 'WEEKEND: 1 MOCK', 'NO BURNOUT'. BOTTOM CTA animated: 'LIKE • SHARE • SUBSCRIBE • COMMENT YOUR STREAM'. Background voices: Habit check 'TICK', 'TICK', 'TICK', final subscribe bell 'DING', cheer 'GO!'. SFX: Checkmarks, bell. Voiceover: 'Like, share, subscribe, comment your stream! 20 mahine hain - foundation strong banao, aaj se!' Transition: End screen 'BUILD FOUNDATIONS'.",
                voiceover_text="Like, share, subscribe, comment your stream! 20 mahine hain - foundation strong banao, aaj se!",
                visual_cues=["BUILD FOUNDATIONS", "LIKE • SHARE • SUBSCRIBE", "YOUR STREAM?", "2-3 HOURS DAILY"],
                transition_note="End screen with thumbnail"
            )
        ]
        return VideoScript(
            topic=plan.topic,
            title="🚨 20 Months to JEE 2028: Start Right Not Fast | 11th Grade Roadmap",
            description="11th grade me ho? 20 months hain - kaafi time hai agar strategy sahi ho. Foundation first, advanced later. School+JEE integration, simple daily habits, no burnout. Complete roadmap!",
            tags=["JEE", "JEE2028", "11thGrade", "Foundation", "Roadmap"],
            clips=clips,
            thumbnail_concept="20 MONTHS LEFT",
            google_flow_context_prompt=self._build_google_flow_context_prompt(plan)
        )

    def _counseling_fallback(self, plan: ContentPlan) -> VideoScript:
        clips = [
            ClipScript(
                clip_index=1,
                duration_seconds=15,
                flow_prompt="Talking head, extreme close-up, static camera, urgent alert style. Character: URGENT ALERT, wide eyes, raised eyebrows, hand to ear 'listen', lean in aggressive. Background: Emergency red gradient (#FF0000 to #8B0000), multiple countdown timers pulsing: 'CSAB SPECIAL: 3 DAYS', 'IPU SPOT R2: 5 DAYS', 'JAC SPOT: 7 DAYS'. Lighting: Emergency red key light flashing, strobe practicals, dramatic high contrast. Text TOP: '🚨 DEADLINES THIS WEEK' large red pulse. MIDDLE: 'CSAB SPECIAL + IPU SPOT' animated. BOTTOM: 'AUG 18-20' red bold. Background voices: Air raid siren faint, student panic whispers 'bhaiya deadline...', 'kya karu...'. SFX: Alarm beep-beep-beep, clock ticking fast. Voiceover: 'Bhaiya, CSAB Special Round aur IPU Spot Round 2 - deadlines AUG 18 to 20! Abhi action lo!' Transition: Hard cut to calendar dates.",
                voiceover_text="Bhaiya, CSAB Special Round aur IPU Spot Round 2 - deadlines AUG 18 to 20! Abhi action lo!",
                visual_cues=["🚨 DEADLINES THIS WEEK", "CSAB SPECIAL", "IPU SPOT R2", "AUG 18-20"],
                transition_note="Hard cut to key dates"
            ),
            ClipScript(
                clip_index=2,
                duration_seconds=15,
                flow_prompt="Talking head + animated calendar/process flowchart. Character: INFORMATIVE ORGANIZED, finger counting dates 1-2-3, checklist gesture each item, calm authoritative. Background: Clean calendar August view, dates 18, 19, 20 highlighted pulsing. Process flowchart right side: 'REGISTER → CHOICE FILL → LOCK → SEAT ALLOT → REPORT'. Lighting: Professional cool white, clean key, soft fill. Text: Each date + action animates in: 'AUG 18: CSAB REGISTER', 'AUG 19: CHOICE FILL', 'AUG 20: LOCK CHOICES', 'IPU: SPOT R2 NOTICE OUT'. Background voices: Calendar 'THUD' each date, pen 'SCRATCH' checklist. SFX: 'PING' date highlight, 'WHOOSH' flowchart. Voiceover: 'CSAB Special: register by 18, choice fill 19, lock 20. IPU Spot Round 2 new notice - check official site. JAC spot round bhi chal raha.' Transition: Whip pan to document stack.",
                voiceover_text="CSAB Special: register by 18, choice fill 19, lock 20. IPU Spot Round 2 new notice - check official site. JAC spot round bhi chal raha.",
                visual_cues=["CSAB DATES", "IPU NOTICE", "JAC SPOT", "PROCESS FLOW"],
                transition_note="Whip pan to document checklist"
            ),
            ClipScript(
                clip_index=3,
                duration_seconds=15,
                flow_prompt="Talking head + document stack sliding in with checks. Character: HELPFUL THOROUGH, checking off invisible list, nodding each item, warm reassuring. Background: Document stack floating, each doc slides up with green checkmark: 'ALLOtMENT LETTER ✓', 'DOCUMENT VERIFICATION ✓', 'FEE RECEIPT ✓', 'ID PROOF ✓', 'PHOTOS ✓'. Common mistakes red X: 'WRONG CATEGORY ✗', 'MISSING SIGNATURE ✗', 'EXPIRED ID ✗'. Lighting: Warm reassuring, soft key, gentle rim. Text: Each doc animates with check/X. Background voices: Paper shuffle 'flap', stamp 'APPROVED' thud, error 'BUZZ' on red X. SFX: Stamp, buzz, check chime. Voiceover: 'Allotment letter, doc verification, fee receipt, ID proof, photos - sab ready rakho. Common mistakes: wrong category, missing sign, expired ID - avoid karo!' Transition: Zoom to India map.",
                voiceover_text="Allotment letter, doc verification, fee receipt, ID proof, photos - sab ready rakho. Common mistakes: wrong category, missing sign, expired ID - avoid karo!",
                visual_cues=["DOC CHECKLIST", "ALLLOTMENT ✓", "COMMON MISTAKES ✗", "AVOID ERRORS"],
                transition_note="Zoom to state map"
            ),
            ClipScript(
                clip_index=4,
                duration_seconds=15,
                flow_prompt="Talking head, close-up, direct call to action. Character: DIRECT URGENT CARING, pointing down at 'comment', intense but caring eye contact, 'tell me' gesture. Background: Stylized India map, states pulse with counseling activity: Maharashtra, Karnataka, Tamil Nadu, UP, Bihar, Delhi, Jharkhand highlighted. Lighting: Warm key on face, cool rim, map glow. Text: TOP 'COMMENT YOUR STATE' animated. MIDDLE: 'GET STATE-SPECIFIC INFO' pulsing. BOTTOM CTA: 'LIKE • SHARE • SUBSCRIBE • COMMENT YOUR STATE'. Background voices: Map 'PING' each state highlight, faint 'Maharashtra... Karnataka... UP...', final bell 'DING'. SFX: Ping, subscribe bell. Voiceover: 'Like, share, subscribe, comment YOUR state! State-specific counseling info dunga - jaldi karo, seats ja rahi hain!' Transition: End screen 'DEADLINES THIS WEEK' thumbnail.",
                voiceover_text="Like, share, subscribe, comment YOUR state! State-specific counseling info dunga - jaldi karo, seats ja rahi hain!",
                visual_cues=["COMMENT YOUR STATE", "STATE MAP", "LIKE • SHARE • SUBSCRIBE", "SEATS FILLING"],
                transition_note="End screen with thumbnail"
            )
        ]
        return VideoScript(
            topic=plan.topic,
            title="🚨 CSAB Special + IPU Spot Round: Deadlines THIS WEEK | Act Now",
            description="CSAB Special Round, IPU Spot Round 2, JAC Spot - deadlines Aug 18-20! Complete dates, process, document checklist, and state-specific guidance. Don't lose your seat - act TODAY!",
            tags=["JEE", "CSAB2026", "IPUCounseling", "SpotRound", "Deadlines"],
            clips=clips,
            thumbnail_concept="DEADLINES THIS WEEK",
            google_flow_context_prompt=self._build_google_flow_context_prompt(plan)
        )

    def _generic_fallback(self, plan: ContentPlan) -> VideoScript:
        clips = []
        for i, section in enumerate(plan.structure_outline[:4], 1):
            clip = ClipScript(
                clip_index=i,
                duration_seconds=15,
                flow_prompt=f"Talking head, medium shot, urgent tone. Character: BHAIYA URGENT, direct eye contact, hand gestures emphasizing key points. Background: {plan.urgency_hooks[0] if plan.urgency_hooks else '🚨 URGENT'} themed gradient. Lighting: High contrast, dramatic key light. Text overlay: '{section}'. Voiceover in Hinglish. Transition: Hard cut.",
                voiceover_text=section,
                visual_cues=[plan.urgency_hooks[0] if plan.urgency_hooks else "🚨 URGENT"],
                transition_note="Next section" if i < 4 else "End screen"
            )
            clips.append(clip)
        return VideoScript(
            topic=plan.topic,
            title=plan.topic[:80],
            description=f"{plan.topic}. {plan.cta}",
            tags=["JEE", "Preparation", "Strategy"],
            clips=clips,
            thumbnail_concept=plan.urgency_hooks[0].replace("🚨", "").strip() if plan.urgency_hooks else "TAKE ACTION",
            google_flow_context_prompt=self._build_google_flow_context_prompt(plan)
        )

    def _validate_script(self, script: VideoScript, plan: ContentPlan) -> bool:
        if not script.clips or len(script.clips) < 3:
            return False
        if script.total_duration_seconds < 45 or script.total_duration_seconds > 65:
            return False
        for clip in script.clips:
            if not clip.flow_prompt or len(clip.flow_prompt) < 50:
                return False
            if not clip.voiceover_text or len(clip.voiceover_text) < 10:
                return False
        # Check no personalized CTA
        personalized_phrases = ["i'll tell", "i'll reply", "dm me", "message me", "reply to", "tell your"]
        full_text = " ".join([c.voiceover_text.lower() for c in script.clips])
        if any(p in full_text for p in personalized_phrases):
            return False
        return True


def get_script_writer() -> ScriptWriterAgent:
    """Factory function for dependency injection."""
    return ScriptWriterAgent()


def run_script_writer(run_id: str) -> VideoScript:
    """Entry point for orchestrator."""
    run = db.get_run(run_id)
    if not run or not run.content_plan:
        raise ValueError(f"Run {run_id} not found or missing content plan")

    agent = ScriptWriterAgent()
    return agent.write_script(run)