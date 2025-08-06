//
//  ProfileLogoutService.swift
//  ImageFeed
//
//  Created by Волошин Александр on 8/3/25.

import Foundation
// Обязательный импорт
import WebKit

final class ProfileLogoutService {
   static let shared = ProfileLogoutService()
  
   private init() { }

    func logout() {
        OAuth2TokenStorage.shared.removeToken()

        cleanCookies()

        ProfileService.shared.reset()
        ProfileImageService.shared.reset()
//        ImagesListService.shared.reset()

        switchToSplashViewController()
    }
    
    func switchToSplashViewController() {
        guard let window = UIApplication.shared.windows.first else { return }
        let authController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "AuthViewController")
        window.rootViewController = authController
    }

   private func cleanCookies() {
      // Очищаем все куки из хранилища
      HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
      // Запрашиваем все данные из локального хранилища
      WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
         // Массив полученных записей удаляем из хранилища
         records.forEach { record in
            WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
         }
      }
   }
}
    
