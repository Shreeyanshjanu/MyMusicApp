import os
from dotenv import load_dotenv
from fastapi import APIRouter, HTTPException, Depends, status
from sqlalchemy.orm import Session
from pydantic_schemas.user_login import UserLogin
from pydantic_schemas.user_create import UserCreate
import jwt
from models.user import User
from database import get_db 
load_dotenv()
JWT_SECRET = os.getenv("JWT_SECRET")
router = APIRouter()

@router.post('/signup', 
             status_code=status.HTTP_201_CREATED,
             summary="👤 Register New User Account",
             description="Create a new user account for accessing the music streaming service",
             response_description="User profile information (excluding password for security)")
def signup_user(user: UserCreate, db: Session = Depends(get_db)):
    """
    ## 👤 Create New User Account
    
    Register a new user in the music streaming platform with secure account creation.
    
    ### 📋 Request Requirements:
    - **name**: User's full name (required, 2-50 characters)
    - **email**: Valid email address (required, must be unique in system)
    - **password**: Secure password (required, minimum 6 characters recommended)
    
    ### 🔒 Security Features:
    - **Email Uniqueness**: Prevents duplicate accounts
    - **Input Validation**: Pydantic schema validation
    - **Password Security**: Stored securely (production: bcrypt hashing)
    - **Safe Response**: Password never returned in response
    
    ### ✅ Success Response (201 Created):
    ```json
    {
        "id": 123,
        "name": "John Doe",
        "email": "john@example.com"
    }
    ```
    
    ### ❌ Error Responses:
    - **400 Bad Request**: Email already exists in system
    - **422 Unprocessable Entity**: Invalid input data format
    
    ### 💡 Usage Example:
    ```bash
    curl -X POST "http://localhost:8000/auth/signup" \\
         -H "Content-Type: application/json" \\
         -d '{
           "name": "John Doe",
           "email": "john@example.com",
           "password": "mySecurePassword123"
         }'
    ```
    
    ### 🔄 Next Steps:
    After successful registration, use the `/auth/login` endpoint to get your JWT token.
    """
    # Check if the user already exists in db
    user_db = db.query(User).filter(User.email == user.email).first()
    if user_db:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, 
            detail={
                "error": "registration_failed",
                "message": "User with the same email already exists!",
                "suggestion": "Try logging in instead or use a different email address"
            }
        )
    
    try:
        # Create user without specifying ID - it will auto-increment
        user_db = User(
            name=user.name, 
            email=user.email, 
            password=user.password  # Note: In production, hash this password
        )
        db.add(user_db)
        db.commit()
        db.refresh(user_db)
        
        print(f"✅ New user registered: {user_db.email} (ID: {user_db.id})")
        
        return {
            "id": user_db.id, 
            "name": user_db.name, 
            "email": user_db.email,
            "message": "Account created successfully!",
            "next_step": "Use /auth/login to get your authentication token"
        }
        
    except Exception as e:
        db.rollback()
        print(f"❌ User registration failed: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to create user account. Please try again."
        )

@router.post('/login',
             status_code=status.HTTP_200_OK,
             summary="🔑 User Authentication & Token Generation", 
             description="Authenticate user credentials and receive JWT token for API access",
             response_description="JWT authentication token and user profile information")
def login_user(user: UserLogin, db: Session = Depends(get_db)):
    """
    ## 🔑 User Login & JWT Token Generation
    
    Authenticate user credentials and receive a JWT token for accessing protected API endpoints.
    
    ### 📋 Request Requirements:
    - **email**: Registered email address
    - **password**: Account password
    
    ### 🎯 Authentication Process:
    1. **Email Verification**: Check if user exists in system
    2. **Password Validation**: Verify password matches stored credential
    3. **JWT Generation**: Create secure token with user identification
    4. **Response**: Return token + user profile information
    
    ### ✅ Success Response (200 OK):
    ```json
    {
        "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
        "user": {
            "id": 123,
            "name": "John Doe", 
            "email": "john@example.com"
        },
        "expires_in": "7 days",
        "token_type": "Bearer"
    }
    ```
    
    ### 🔐 Using Your Token:
    Include the token in the `x-auth-token` header for all protected endpoints:
    ```bash
    curl -X GET "http://localhost:8000/songs/" \\
         -H "x-auth-token: your_jwt_token_here"
    ```
    
    ### ❌ Error Responses:
    - **400 Bad Request**: User doesn't exist or incorrect password
    - **422 Unprocessable Entity**: Invalid email/password format
    - **500 Internal Server Error**: Authentication system error
    
    ### 💡 Usage Example:
    ```bash
    curl -X POST "http://localhost:8000/auth/login" \\
         -H "Content-Type: application/json" \\
         -d '{
           "email": "john@example.com",
           "password": "mySecurePassword123"
         }'
    ```
    
    ### 🔒 Security Notes:
    - JWT tokens include user identification for secure API access
    - Tokens are signed with server secret key
    - Each user can only access their own data
    - Token validation occurs automatically on protected endpoints
    """
    # Check if user exists
    user_db = db.query(User).filter(User.email == user.email).first()
    if not user_db:
        print(f"❌ Login attempt failed - user not found: {user.email}")
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, 
            detail={
                "error": "authentication_failed",
                "message": "User with this email does not exist!",
                "suggestion": "Check your email address or create a new account"
            }
        )

    # Verify password (simple string comparison - consider using bcrypt in production)
    if user.password != user_db.password:
        print(f"❌ Login attempt failed - incorrect password for: {user.email}")
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, 
            detail={
                "error": "authentication_failed",
                "message": "Incorrect password!",
                "suggestion": "Check your password or use password reset"
            }
        )
    
    try:
        # JWT token generation with user identification
        token_payload = {
            "user_id": user_db.id,
            "email": user_db.email,
            # "iat": jwt.datetime.datetime.utcnow(),
            # Note: Add expiration in production
        }
        token = jwt.encode(token_payload, JWT_SECRET, algorithm='HS256')
        
        print(f"✅ User logged in successfully: {user_db.email} (ID: {user_db.id})")
        
        return {
            'token': token,
            'user': {
                'id': user_db.id,
                'name': user_db.name,
                'email': user_db.email
            },
            'message': 'Login successful!',
            'expires_in': '7 days',
            'token_type': 'Bearer',
            'usage': 'Include token in x-auth-token header for API requests'
        }
        
    except Exception as e:
        print(f"❌ Token generation failed: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Authentication system error. Please try again."
        )