from ore import function


@function
def repeat(text: str, times: int = 1) -> str:
    return " ".join([text] * times)
