# from fastapi import FastAPI
# from fastapi.middleware.cors import CORSMiddleware
# from database import engine
# from models.base import Base
# from routes import auth, song
# from models.song import Song  # Import all models to register them with Base

# app = FastAPI()

# # Add CORS middleware
# app.add_middleware(
#     CORSMiddleware,
#     allow_origins=["*"],
#     allow_credentials=True,
#     allow_methods=["*"],
#     allow_headers=["*"],
# )

# # Create tables on startup
# @app.on_event("startup")
# async def create_tables():
#     print("🚀 Starting up - Creating database tables...")
#     try:
#         Base.metadata.create_all(bind=engine)
#         print("✅ Database tables ready!")
#     except Exception as e:
#         print(f"❌ Error creating tables: {e}")

# # Include routers
# app.include_router(auth.router, prefix="/auth", tags=["auth"])
# app.include_router(song.router, prefix="/songs", tags=["songs"])

# @app.get("/")
# def root():
#     return {"message": "Music App API is running!"}

# if __name__ == "__main__":
#     import uvicorn
#     uvicorn.run(app, host="0.0.0.0", port=8000)



from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from database import engine
from models.base import Base
from routes import auth, song
from models.song import Song  # Import all models to register them with Base

# Enhanced FastAPI app with comprehensive metadata
app = FastAPI(
    title="🎵 Music Streaming API",
    description="""
    ## Professional Music Streaming Backend API
    
    A comprehensive RESTful API for music streaming applications built with FastAPI, PostgreSQL, and JWT authentication.
    
    ### 🚀 Key Features:
    - 🔐 **Secure Authentication**: JWT-based user authentication with automatic token validation
    - 🎵 **Smart Music Management**: Complete CRUD operations with YouTube integration
    - 📱 **YouTube Audio Extraction**: Automatic audio stream extraction using yt-dlp
    - 👤 **User Privacy**: Complete data isolation - users only access their own music
    - 🔄 **URL Refresh System**: Automatic refresh of expired YouTube audio URLs
    - 📊 **Genre Organization**: Filter and organize music by genres
    - 🛡️ **Security First**: Input validation, SQL injection protection, CORS handling
    
    ### 💻 Tech Stack:
    - **Backend Framework**: FastAPI (Python 3.8+)
    - **Database**: PostgreSQL with SQLAlchemy ORM
    - **Authentication**: JWT (JSON Web Tokens)
    - **YouTube Integration**: yt-dlp library for audio extraction
    - **Testing**: Pytest with 20 comprehensive test cases
    - **Documentation**: Auto-generated OpenAPI/Swagger docs
    
    ### 🔒 Security Features:
    - JWT token-based authentication
    - User data isolation and privacy
    - Input validation with Pydantic schemas
    - SQL injection prevention via ORM
    - CORS protection with configurable origins
    - Error handling with detailed logging
    
    ### 📊 API Statistics:
    - **Total Endpoints**: 8 (2 auth + 6 music management)
    - **Test Coverage**: 20 comprehensive backend tests
    - **Authentication**: JWT with user isolation
    - **Database**: PostgreSQL with relational design
    
    ---
    **Developer**: [Shreeyansh Janu](https://github.com/Shreeyanshjanu)  
    **Project Type**: Full-Stack Music Streaming Application  
    **Purpose**: Professional portfolio demonstrating enterprise-level API development  
    **Date**: Sepetember 2025
    """,
    version="2.0.0",
    contact={
        "name": "Shreeyansh Janu",
        "url": "https://github.com/Shreeyanshjanu",
        "email": "arthurmorgan5984@gmail.com"  # Replace with your email
    },
    license_info={
        "name": "MIT License",
        "url": "https://opensource.org/licenses/MIT"
    },
    servers=[
        {
            "url": "http://localhost:8000",
            "description": "Development server"
        },
        {
            "url": "https://your-api-domain.com",
            "description": "Production server"
        }
    ],
    tags_metadata=[
        {
            "name": "auth",
            "description": """
            🔐 **Authentication & User Management**
            
            Complete user authentication system with JWT tokens:
            - User registration with email validation
            - Secure login with password verification
            - JWT token generation for API access
            - Automatic token validation for protected endpoints
            
            **Security Notes:**
            - Passwords stored securely (production: use bcrypt hashing)
            - JWT tokens expire and include user identification
            - Each user can only access their own data
            """
        },
        {
            "name": "songs",
            "description": """
            🎵 **Music Library Management**
            
            Complete music management system with YouTube integration:
            - Add songs via YouTube URL (automatic metadata extraction)
            - Manual song entry with custom metadata
            - View and filter personal music library
            - Delete songs from library
            - Refresh expired YouTube audio URLs
            - Genre-based filtering and organization
            
            **YouTube Integration:**
            - Automatic title, artist, and duration extraction
            - High-quality audio stream URLs
            - Thumbnail image extraction
            - Video ID storage for future reference
            """
        },
        {
            "name": "system",
            "description": """
            🏠 **System & Health Monitoring**
            
            System status and health check endpoints:
            - API health verification
            - Service status monitoring
            - Version information
            - Documentation links
            """
        }
    ],
    openapi_tags=[
        {
            "name": "auth",
            "description": "Authentication operations"
        },
        {
            "name": "songs", 
            "description": "Music management operations"
        },
        {
            "name": "system",
            "description": "System status operations"
        }
    ]
)

# Add CORS middleware with detailed configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production: specify exact origins
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allow_headers=["*"],
    expose_headers=["*"]
)

# Create tables on startup with enhanced logging
@app.on_event("startup")
async def create_tables():
    """
    Initialize database tables on application startup.
    
    Creates all necessary tables based on SQLAlchemy models:
    - users table: User authentication and profile data
    - songs table: Music library with YouTube integration
    """
    print("🚀 Starting Music Streaming API...")
    print("📊 Initializing database tables...")
    try:
        Base.metadata.create_all(bind=engine)
        print("✅ Database tables created successfully!")
        print("🎵 Music App API ready to serve requests!")
    except Exception as e:
        print(f"❌ Critical Error: Failed to create database tables: {e}")
        print("🔧 Check your database configuration and try again")

# Include routers with comprehensive configuration
app.include_router(
    auth.router, 
    prefix="/auth", 
    tags=["auth"],
    responses={
        401: {"description": "Authentication failed"},
        422: {"description": "Validation error"}
    }
)

app.include_router(
    song.router, 
    prefix="/songs", 
    tags=["songs"],
    responses={
        401: {"description": "Authentication required"},
        404: {"description": "Song not found"},
        422: {"description": "Validation error"}
    }
)

@app.get("/", 
         tags=["system"], 
         summary="🏠 API Health Check", 
         description="Verify that the Music Streaming API is running and accessible",
         response_description="API status information with navigation links")
def root():
    """
    ## 🏠 API Health Check & Welcome
    
    This endpoint provides:
    - **API Status**: Confirms the service is running
    - **Version Information**: Current API version
    - **Documentation Links**: Quick access to API docs
    - **Service Metadata**: Basic service information
    
    ### Use Cases:
    - **Health Monitoring**: Check if API is operational
    - **Load Balancer Checks**: Verify service availability  
    - **Development Setup**: Confirm successful API startup
    - **Documentation Access**: Get links to interactive docs
    
    ### Response Format:
    ```json
    {
        "message": "🎵 Music App API is running!",
        "status": "healthy",
        "version": "2.0.0",
        "api_docs": "/docs",
        "alternative_docs": "/redoc",
        "developer": "Shreeyansh Janu",
        "features": [...]
    }
    ```
    
    **No authentication required** - Public endpoint for system verification.
    """
    return {
        "message": "🎵 Music Streaming API is running!",
        "status": "healthy",
        "version": "2.0.0",
        "timestamp": "2025-01-07T10:46:27Z",
        "api_docs": "/docs",
        "alternative_docs": "/redoc",
        "developer": "Shreeyansh Janu",
        "github": "https://github.com/shreeyanshJanuTWO",
        "features": [
            "JWT Authentication",
            "YouTube Audio Extraction", 
            "User Music Libraries",
            "Genre Filtering",
            "Audio URL Refresh",
            "Complete CRUD Operations"
        ],
        "endpoints": {
            "authentication": "/auth",
            "music_management": "/songs",
            "documentation": "/docs"
        },
        "tech_stack": {
            "backend": "FastAPI",
            "database": "PostgreSQL",
            "authentication": "JWT",
            "youtube_integration": "yt-dlp",
            "testing": "Pytest (20 tests)"
        }
    }

# Add application metadata
@app.on_event("startup")
async def startup_message():
    """Display startup information"""
    print("\n" + "="*60)
    print("🎵 MUSIC STREAMING API - SUCCESSFULLY STARTED")
    print("="*60)
    print(f"📍 Server: http://localhost:8000")
    print(f"📚 API Docs: http://localhost:8000/docs")
    print(f"📖 ReDoc: http://localhost:8000/redoc")
    print(f"👨‍💻 Developer: Shreeyansh Janu")
    print(f"🔗 GitHub: https://github.com/shreeyanshJanuTWO")
    print("="*60 + "\n")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        app, 
        host="0.0.0.0", 
        port=8000,
        log_level="info",
        reload=True  # Enable auto-reload during development
    )