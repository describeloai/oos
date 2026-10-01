from datetime import date

from ore import function


class date:  # tapa a datetime.date
    pass


@function
def repetir(dia: date) -> str:
    return str(dia)
