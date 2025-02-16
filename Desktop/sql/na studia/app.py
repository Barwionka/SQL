from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import uvicorn
from connect_mariadb import (
    wykonaj_przelew, 
    wykonaj_przelew_miedzybankowy,
    odbierz_przelew_zewnetrzny,
    detekcja_odstajacych_przelewow
)

# Inicjalizacja aplikacji FastAPI
app = FastAPI()

# Modele Pydantic dla danych wejściowych
class Przelew(BaseModel):
    numer_konta_nadawcy: int
    numer_konta_odbiorcy: int
    kwota_przelewu: float
    tytul: str
    opis: str = ""

class PrzelewMiedzybankowy(BaseModel):
    numer_konta_nadawcy: str
    numer_konta_odbiorcy: str
    kwota_przelewu: float
    tytul: str

class PrzelewZewnetrzny(BaseModel):
    numer_konta_nadawcy: str
    numer_konta_odbiorcy: str
    kwota_przelewu: float
    tytul: str

# Endpoint do wykonania przelewu wewnętrznego
@app.post("/wykonaj_przelew/")
def wykonaj_przelew_endpoint(przelew: Przelew):
    try:
        wykonaj_przelew(
            przelew.numer_konta_nadawcy, 
            przelew.numer_konta_odbiorcy, 
            przelew.kwota_przelewu, 
            przelew.tytul,
            przelew.opis
        )
        return {"message": f"Przelew o kwocie {przelew.kwota_przelewu} został wykonany."}
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Błąd: {str(e)}")

# Endpoint do wykonania przelewu międzybankowego
@app.post("/wykonaj_przelew_miedzybankowy/")
def wykonaj_przelew_miedzybankowy_endpoint(przelew: PrzelewMiedzybankowy):
    try:
        wykonaj_przelew_miedzybankowy(
            przelew.numer_konta_nadawcy, 
            przelew.numer_konta_odbiorcy, 
            przelew.kwota_przelewu, 
            przelew.tytul
        )
        return {"message": f"Przelew międzybankowy o kwocie {przelew.kwota_przelewu} został wykonany."}
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Błąd: {str(e)}")

# Endpoint do odbioru przelewu zewnętrznego
@app.post("/odbierz_przelew_zewnetrzny/")
def odbierz_przelew_zewnetrzny_endpoint(przelew: PrzelewZewnetrzny):
    try:
        odbierz_przelew_zewnetrzny(
            przelew.numer_konta_odbiorcy, 
            przelew.numer_konta_nadawcy, 
            przelew.kwota_przelewu, 
            przelew.tytul
        )
        return {"message": f"Przelew zewnętrzny o kwocie {przelew.kwota_przelewu} został odebrany."}
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Błąd: {str(e)}")

# Endpoint do detekcji odstających przelewów
@app.post("/detekcja_odstajacych_przelewow/")
def detekcja_odstajacych_przelewow_endpoint():
    try:
        detekcja_odstajacych_przelewow()
        return {"message": "Odstające przelewy zostały zapisane."}
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Błąd: {str(e)}")

# Uruchomienie aplikacji FastAPI programowo
if __name__ == "__main__":
    uvicorn.run("app:app", host="127.0.0.1", port=8000, reload=True)
