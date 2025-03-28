import json
import urllib.request
import os

def lambda_handler(event, context):
    webhook_url = os.environ['SLACK_WEBHOOK_URL']
    
    try:
        sns_message = event['Records'][0]['Sns']['Message']
        alarm = json.loads(sns_message)

        slack_payload = {
            "text": f"🚨 *{alarm.get('AlarmName', 'Unknown Alarm')}* 발생\n*사유:* {alarm.get('NewStateReason', 'No reason provided')}",
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
