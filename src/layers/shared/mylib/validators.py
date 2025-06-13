def validate_request(event):
    """Very small sample validator."""
    if "request_id" not in event:
        raise ValueError("request_id is required")
    return True
