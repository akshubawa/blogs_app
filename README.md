# Blogs App

A Flutter app that displays a list of blog posts fetched from Firebase Cloud Firestore, with deep linking support to navigate directly to individual blog posts.

## 🚀 Features

- **List of Blogs:** Displays blog posts in a scrollable list with an image, title, summary, and a "Read More" button.  
- **Deep Linking:** Allows users to open the app directly to a specific blog post using deep links.  
- **Responsive UI:** Optimized for mobile devices with smooth transitions.  

## 🏗️ Project Setup

1. **Clone the repository:**  
   ```bash
   git clone https://github.com/akshubawa/blogs_app.git
   ```
2. **Navigate to the project directory:**  
   ```bash
   cd blogs_app
   ```
3. **Install dependencies:**  
   ```bash
   flutter pub get
   ```
4. **Run the app:**  
   ```bash
   flutter run
   ```

## 📦 State Management

This project uses the **Provider** package to manage state efficiently.

## 📄 Folder Structure

```
lib/
│-- models/
│-- providers/
│-- screens/
│-- services/
│-- utils/
│-- main.dart
```

## 🎨 Assumptions & Additional Features

- The blog data is fetched from Firestore with fields like:
  - `imageURL`: URL of the blog post's thumbnail or featured image.  
  - `title`: Title of the blog post.  
  - `summary`: Short summary or description of the blog post.  
  - `content`: Full content of the blog post.  
  - `deeplink`: Deep link for navigating directly to the blog post.  
- Error handling includes simple loading indicators and fallback UIs.  
- Deep linking highlights the target blog post when opened through a link.

## 📧 Contact

For any questions or suggestions, feel free to open an issue or reach out!
