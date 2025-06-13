import json
from functions.account_issue import handler

def test_ok():
    res = handler.lambda_handler({"request_id": "123"}, None)
    assert res["statusCode"] == 200

def test_ng():
    res = handler.lambda_handler({}, None)
    assert res["statusCode"] == 400
