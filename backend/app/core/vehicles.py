"""Tipurile de vehicule.

Aceeasi lista trebuie sa existe si in aplicatie, in
`lib/core/models/vehicle_type.dart`. Sunt sase valori care nu se schimba des;
un endpoint care sa le serveasca ar fi mai mult ceremonial decat folos.
"""

CAR = "masina"
MOTORCYCLE = "motocicleta"
TRUCK = "camion"
SEMI = "tir"
MACHINERY = "utilaj"
OTHER = "altul"

# Ordinea conteaza: asa apar in selectorul din aplicatie, de la cel mai des
# intalnit la cel mai rar.
VEHICLE_TYPES = (CAR, MOTORCYCLE, TRUCK, SEMI, MACHINERY, OTHER)

DEFAULT_VEHICLE_TYPE = CAR


def normalize(value) -> str:
    """Un tip necunoscut devine "masina".

    Un rand stricat in baza de date nu trebuie sa rupa lista de vehicule; in cel
    mai rau caz omul vede iconita gresita si o corecteaza.
    """
    if not value:
        return DEFAULT_VEHICLE_TYPE
    value = str(value).lower()
    return value if value in VEHICLE_TYPES else DEFAULT_VEHICLE_TYPE
