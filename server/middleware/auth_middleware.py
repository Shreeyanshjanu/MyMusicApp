import os
from dotenv import load_dotenv
from fastapi import HTTPException, Header, Depends
from sqlalchemy.orm import Session
from models.user import User  # Remove 'server.' prefix
from database import get_db
import jwt

load_dotenv()
JWT_SECRET = os.getenv("JWT_SECRET")
def auth_middleware(x_auth_token: str = Header(), db: Session = Depends(get_db)):
    try:
        if not x_auth_token:
            raise HTTPException(status_code=401, detail="No Auth token, access denied {auth_middleware file}")
        
        # Decode the token
        verified_token = jwt.decode(x_auth_token, JWT_SECRET, algorithms=['HS256'])

        if not verified_token:
            raise HTTPException(status_code=401, detail="Token verification failed, authorization denied {auth_middleware file}")
        
        # Get the id from token
        uid = verified_token.get('user_id')
        if not uid:
            raise HTTPException(status_code=401, detail="Invalid token payload")

        # Query PostgreSQL database to get the user info
        user = db.query(User).filter(User.id == uid).first()

        if not user:
            raise HTTPException(status_code=404, detail="User not found")

        return {
            "id": user.id, 
            "name": user.name, 
            "email": user.email,
            "token": x_auth_token
        }

    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Token has expired")
    except jwt.InvalidTokenError:
        raise HTTPException(status_code=401, detail="Invalid token")
    except Exception as e:
        raise HTTPException(status_code=401, detail=f"Token verification failed: {str(e)}")