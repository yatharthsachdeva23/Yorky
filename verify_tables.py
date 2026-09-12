import psycopg2
conn = psycopg2.connect(host='127.0.0.1', database='youtube_shorts', user='postgres')
cur = conn.cursor()
tables = ['performance_metrics','traffic_sources','search_terms','retention_curve','audience_device','audience_gender','audience_age','audience_geography','audience_subscriber_status','audience_subtitles','comments_analysis','individual_comments','short_content_classification','short_title_template','end_screen_performance','remix_metrics','realtime_metrics','external_sources','memory_updates','analysis_log']
for t in tables:
    cur.execute(f'SELECT COUNT(*) FROM {t} WHERE video_id=%s', ('yBnFHlmgMFQ',))
    count = cur.fetchone()[0]
    print(f'{t}: {count} rows')
cur.close()
conn.close()