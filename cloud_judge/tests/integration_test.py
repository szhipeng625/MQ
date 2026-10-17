import json
import os
import sys
import time
import uuid

import pika

MQ_HOST = sys.argv[1] if len(sys.argv) > 1 else "127.0.0.1"
MQ_PORT = int(os.environ.get("MQ_PORT", "5672"))
TASK_QUEUE = os.environ.get("TASK_QUEUE", "oj.judge")
RESULT_QUEUE = os.environ.get("RESULT_QUEUE", "oj.judge.result")
TIMEOUT = int(os.environ.get("CJ_TEST_TIMEOUT", "90"))

CODE = "#include <cstdio>\nint main(){int a,b;scanf(\"%d %d\",&a,&b);printf(\"%d\\n\",a+b);return 0;}"

task_id = str(uuid.uuid4())
task = {
    "task_id": task_id,
    "language": "cpp",
    "code": CODE,
    "test_cases": [{"input": "1 2\n", "expected": "3\n"}],
}

conn = pika.BlockingConnection(pika.ConnectionParameters(MQ_HOST, MQ_PORT))
ch = conn.channel()
ch.queue_declare(queue=TASK_QUEUE, durable=True)
ch.queue_declare(queue=RESULT_QUEUE, durable=True)
ch.basic_publish(exchange="", routing_key=TASK_QUEUE, body=json.dumps(task))
print("[test] submitted task " + task_id, flush=True)

deadline = time.time() + TIMEOUT
received = []
while time.time() < deadline:
    method, props, body = ch.basic_get(queue=RESULT_QUEUE, auto_ack=True)
    if body:
        text = body.decode("utf-8", "replace")
        print("[test] result-queue message: " + text, flush=True)
        received.append(text)
        if task_id in text:
            print("[test] PASS: received result for our task", flush=True)
            sys.exit(0)
    else:
        time.sleep(2)

if received:
    print("[test] PASS: consumer produced result messages", flush=True)
    sys.exit(0)
print("[test] FAIL: no result message within timeout", flush=True)
sys.exit(1)
