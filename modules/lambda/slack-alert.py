import json
import urllib.request
import os
import base64
import gzip
import re

def lambda_handler(event, context):
    webhook_url = os.environ['SLACK_WEBHOOK_URL']

    try:
        # 1. CloudWatch 로그 데이터 디코딩
        cw_data = event['awslogs']['data']
        compressed_payload = base64.b64decode(cw_data)
        uncompressed_payload = gzip.decompress(compressed_payload)
        logs = json.loads(uncompressed_payload)

        # 2. 로그 메시지 추출
        log_events = logs['logEvents']
        error_messages = [e['message'] for e in log_events]

        # 3. 사유 추출: POST_NOT_FOUND 같이 대문자 에러코드 탐색
        reason = "에러 메시지를 찾을 수 없습니다."
        for msg in error_messages:
            match = re.search(r'([A-Z_]{3,})', msg)
            if match:
                reason = match.group(1)
                break

        # 4. Slack 메시지 전송
        slack_payload = {
            "text": f"🚨 *Spring 서버 ERROR 발생*\n*사유:* `{reason}`"
        }

        req = urllib.request.Request(
            webhook_url,
            data=json.dumps(slack_payload).encode('utf-8'),
            headers={'Content-Type': 'application/json'}
        )
        urllib.request.urlopen(req)

        return {
            'statusCode': 200,
            'body': 'Slack message sent successfully!'
        }

    except Exception as e:
        print("Error:", str(e))
        return {
            'statusCode': 500,
            'body': f"Failed to send Slack message: {str(e)}"
        }
