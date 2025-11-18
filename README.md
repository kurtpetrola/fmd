# 🏠 Find My Dorm

> [!NOTE]
> This application is currently not production-ready. It is developed and maintained solely for **educational, portfolio, and demonstration purposes**. Please do not use it for real-world, critical accommodation searches or rely on the data for decision-making.

---

**Find My Dorm is a dedicated location-based application designed to help individuals find suitable long-term accommodation and dormitories near Pangasinan.** By simplifying the search process, the app provides a user-friendly platform for anyone—whether a student, professional, or long-term visitor—to explore, compare, and locate safe and comfortable lodging options based on their specific needs and location preferences in the area.

## ✨ Features

We aim to simplify your dormitory search with these core functionalities:

- **Dormitory Listings:** Browse a comprehensive list of dormitory options specifically located in and around the Pangasinan region.
- **Interactive Map View:** Visually explore all dormitories on an **interactive map**, allowing users to easily check their proximity to universities, transportation hubs, and other essential services.
- **Dynamic Routing:** Powered by OpenRouteService API, providing accurate route generation and path visualization between dormitories and nearby landmarks.
- **Smart Filtering & Sorting:** Quickly narrow down search results using **advanced filters** (e.g., gender-specific, location) to find the perfect match.
- **Favorites & Comparison:** Save preferred dormitories to a **Favorites List** for easy re-access and side-by-side comparison.

## 📥 Installation

You can download the latest **Android APK** file and install the application manually from the **[releases page](https://github.com/kurtpetrola/fmd/releases)**.

## 💻 Tech Stack

| Component            | Technology               | Purpose                                                                        |
| :------------------- | :----------------------- | :----------------------------------------------------------------------------- |
| **Mobile Framework** | **Flutter**              | Cross-platform UI development for iOS and Android.                             |
| **Database**         | **SQLite**               | Local, lightweight, and fast data persistence for dorm listings and user data. |
| **Security**         | **`bcrypt`**             | Used for secure one-way hashing of user passwords.                             |
| **Mapping**          | **`flutter_map`**        | Provides interactive map views and location tracking.                          |
| **Routing API**      | **OpenRouteService API** | Enables dynamic route generation and location-based mapping features.          |

## 🚀 Getting Started

Follow these steps to get a copy of the project running on your local machine for development and testing.

### Prerequisites

1.  **Flutter SDK:** Make sure you have Flutter installed.
2.  **IDE:** Visual Studio Code or Android Studio.

### Installation

1.  Clone the repository and navigate to the directory:

    ```bash
    git clone https://github.com/kurtpetrola/fmd.git
    cd fmd
    ```

2.  Install dependencies:
    ```bash
    flutter pub get
    ```
3.  Run the application:
    ```bash
    flutter run
    ```
    _(Ensure you have a device or emulator running.)_

## 🔑 Demo Accounts

Use the following accounts to quickly explore the application's different user roles (User and Admin) without needing to register:

- **User Account**
  - **Email:** `test@fmd.com`
  - **Password:** `test123`
- **Admin Account**
  - **Email:** `admin@fmd.com`
  - **Password:** `admin123`

## 🛠 To Do & Future Enhancements

The following tasks are prioritized for future development:

- **Data Expansion:** Significantly **expand the dormitory database** to offer a wider variety of options.
- **Advanced Filtering:** Implement new filters based on **amenities** (Wi-Fi, laundry, parking), **price range**, and **real-time availability**.
- **Community Integration:** Integrate **user reviews and ratings** for dormitories to enhance trust and transparency.
- **Map Enhancements:** Upgrade the interactive map with **real-time location updates** and detailed neighborhood information.

## 🤝 Contributing

We welcome contributions! If you have suggestions or find bugs, please open an issue or submit a pull request.

1.  Fork the Project
2.  Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your Changes (`git commit -m 'feat: Add AmazingFeature'`)
4.  Push to the Branch (`git push origin feature/AmazingFeature`)
5.  Open a Pull Request

## 💖 Support & Connect

If you found this repository helpful, consider leaving a ⭐ on **[fmd](https://github.com/kurtpetrola/fmd/stargazers)**.  
You can also **[follow me](https://github.com/kurtpetrola)** on GitHub to stay updated with my latest projects.

## 📄 License

This project is licensed under the **MIT License** - see the **[LICENSE](https://github.com/kurtpetrola/fmd/blob/main/LICENSE)** file for details.
