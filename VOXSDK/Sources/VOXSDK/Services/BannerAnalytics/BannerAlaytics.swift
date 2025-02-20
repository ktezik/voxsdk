protocol BannerAlaytics {
    
    /// Баннер загружен для отрисовки
    func loaded()
    /// Баннер отрисовался
    func shown()
    /// Баннер виден пользователю
    func visible()
    /// Пользователь нажал на баннер
    func click()
    /// Пользователь закрыл баннер
    func close()
    
}
