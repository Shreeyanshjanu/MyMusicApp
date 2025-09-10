# 🎵 MyMusicApp

A full-stack music streaming application featuring a Flutter frontend and a FastAPI backend, with PostgreSQL and Firebase integration for scalable data storage. This project demonstrates secure authentication, dynamic music management, and modern API design.

---

## 🚀 Features

- **User Authentication**: Secure registration and login with JWT tokens.
- **Music Library Management**: Users can add, view, and manage songs.
- **Dynamic Song Details**: Supports audio/video links, thumbnails, and genres.
- **Relational Models**: Users and songs linked using foreign keys.
- **API Documentation**: Auto-generated docs with Swagger/OpenAPI.
- **Environment Variables**: Sensitive credentials managed via `.env`.
- **Firebase Integration**: Optionally store data in Firebase for scalability.
- **Flutter Frontend**: Cross-platform mobile UI for music streaming.

---

## 🛠️ Tech Stack

- **Frontend**: Flutter
- **Backend**: FastAPI (Python)
- **Database**: PostgreSQL
- **Authentication**: JWT
- **ORM**: SQLAlchemy
- **API Testing**: Postman
- **Deployment**: not deployed yet

---

## 📦 Project Structure

```
mymusicapp/
├── server/           # FastAPI backend
│   ├── main.py
│   ├── models/
│   ├── database.py
│   ├── ...
├── client/      # Flutter frontend
│   ├── lib/
│   ├── pubspec.yaml
│   ├── ...
├── README.md
├── .env.example
```

---


## 📝 API Documentation

- Visit `http://127.0.0.1:8000/docs` for interactive Swagger UI.
- Postman collection available in the repo for testing endpoints.

---

## 🔒 Security

- All passwords are securely hashed.
- Environment variables handle sensitive data.
- JWT-based user authentication.

---

## 📋 Example `.env.example`

```env
DATABASE_URL=postgresql://username:password@localhost:5432/mymusicapp
SECRET_KEY=your_jwt_secret_key
```

---

## 🤝 Contributing

Pull requests and suggestions are welcome!  
Feel free to open issues for feature requests, bug reports, or questions.

---

## 📧 Contact

- **Author:** Shreeyansh Janu
- **LinkedIn:** https://www.linkedin.com/in/shreeyanshjanu/
- **Email:** arthurmorgan5984@gmail.com

---

## ⭐ Acknowledgements

- FastAPI Documentation
- Flutter Documentation
- Firebase Documentation
- SQLAlchemy ORM

---

## 📜 License

This project is licensed under the MIT License.
