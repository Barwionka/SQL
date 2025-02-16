from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import uvicorn
from connect_mariadb import (
    make_a_transfer, 
    receive_external_transfer,
    detect_outlier_transfers
)

# Initialize FastAPI application
app = FastAPI()

# Pydantic models for input data
class Transfer(BaseModel):
    sender_account_number: int
    receiver_account_number: int
    transfer_amount: float
    title: str
    description: str = ""

class BankTransfer(BaseModel):
    sender_account_number: str
    receiver_account_number: str
    transfer_amount: float
    title: str

class ExternalTransfer(BaseModel):
    sender_account_number: str
    receiver_account_number: str
    transfer_amount: float
    title: str

# Endpoint to perform internal transfer
@app.post("/make_transfer/")
def make_transfer_endpoint(transfer: Transfer):
    try:
        make_a_transfer(
            transfer.sender_account_number, 
            transfer.receiver_account_number, 
            transfer.transfer_amount, 
            transfer.title,
            transfer.description
        )
        return {"message": f"Transfer of {transfer.transfer_amount} has been completed."}
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Error: {str(e)}")

# Endpoint to receive external transfer
@app.post("/receive_external_transfer/")
def receive_external_transfer_endpoint(transfer: ExternalTransfer):
    try:
        receive_external_transfer(
            transfer.receiver_account_number, 
            transfer.sender_account_number, 
            transfer.transfer_amount, 
            transfer.title
        )
        return {"message": f"External transfer of {transfer.transfer_amount} has been received."}
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Error: {str(e)}")

# Endpoint for detecting outlier transfers
@app.post("/detect_outlier_transfers/")
def detect_outlier_transfers_endpoint():
    try:
        detect_outlier_transfers()
        return {"message": "Outlier transfers have been recorded."}
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Error: {str(e)}")

# Run the FastAPI application programmatically
if __name__ == "__main__":
    uvicorn.run("app:app", host="127.0.0.1", port=8000, reload=True)
