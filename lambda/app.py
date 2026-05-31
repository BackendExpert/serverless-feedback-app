import json

def lambda_handler(event, context):
    try:
        if event.get('httpMethod') == 'POST' or event.get('requestContext', {}).get('http', {}).get('method') == 'POST':
            body = json.loads(event.get('body', '{}'))
            name = body.get('name', 'Anonymous')
            feedback = body.get('feedback', '')
            
            return {
                'statusCode': 200,
                'headers': {'Content-Type': 'application/json'},
                'body': json.dumps({
                    'message': 'Thank you for your feedback!',
                    'data': {'name': name, 'feedback': feedback}
                })
            }
        
        return {
            'statusCode': 200,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps({'message': 'Serverless Feedback API is running'})
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps({'error': str(e)})
        }
