# Архитектура overlay_glass_core

## Цель

Виджет pull-down окна в стиле iOS 26: по вызову контроллера контент (child) показывается как оверлей с эффектом матового стекла (glassmorphism).

## Компоненты

### 1. `GlassPullDownController`

- **Роль:** управление показом/скрытием оверлея.
- **Методы:**
  - `show(BuildContext context, {Offset? anchor, Alignment? alignment})` — открыть оверлей. Если передан `anchor` (например, от кнопки «⋯»), оверлей позиционируется от этой точки; иначе используется `alignment` (по умолчанию `Alignment.topRight`).
  - `hide()` — закрыть оверлей.
  - `toggle(BuildContext context, ...)` — переключить видимость.
- **Состояние:** хранит ссылку на текущий `OverlayEntry` и на зарегистрированный контент (см. ниже). Опционально — `ValueNotifier<bool> isOpen` для подписки на открыто/закрыто.

### 2. `GlassPullDown` (виджет)

- **Роль:** передаёт в контроллер контент меню и параметры отображения.
- **Параметры:**
  - `controller` — экземпляр `GlassPullDownController`.
  - `child` — виджет меню (список пунктов, иконки и т.д.).
  - `alignment` — выравнивание оверлея, если не задан `anchor` в `show()`.
  - `padding` / `margin` — отступы от краёв или от `anchor`.
  - `width` — опциональная ширина оверлея (например, 280).
  - `barrierColor` / `barrierDismiss` — затемнение фона и закрытие по тапу снаружи.
- **Поведение:** в `initState`/`didUpdateWidget` регистрирует у контроллера builder оверлея (child + стекло + позиция). Сам по себе не рендерит overlay — только «подписывает» контент на контроллер.

### 3. Оверлей (внутренняя реализация)

- **Род:** один или несколько приватных виджетов/функций в `src/`.
- **Задачи:**
  - Вставить в `Overlay` запись с контентом `child`.
  - Обернуть `child` в «стекло»:
    - вариант A: `BackdropFilter` + `ImageFilter.blur` + полупрозрачный фон (простой glass);
    - вариант B: интеграция с `liquid_glass_easy` для более сложного эффекта.
  - Скруглённые углы (`BorderRadius`), тень при необходимости.
  - Позиция: от `anchor` или от `alignment` с учётом `padding`/`width`.
  - Закрытие: тап по барьеру (если `barrierDismiss`), вызов `controller.hide()` из кнопки закрытия или после выбора пункта.

### 4. Поток данных

```
[Экран]
  ├── Контент приложения
  ├── Кнопка «⋯» → onPressed: () => controller.show(context, anchor: buttonOffset)
  └── GlassPullDown(controller: controller, child: MenuContent(...))
        └── регистрирует у controller: «при show() покажи child в оверлее»
```

При вызове `controller.show(context, anchor: ...)` контроллер создаёт `OverlayEntry`, в котором строится стеклянная оболочка и переданный `child`, и вставляет запись в `Overlay.of(context)`.

## Зависимости

- **flutter** — Overlay, BackdropFilter, позиционирование.
- **liquid_glass_easy** (опционально) — для продвинутого glass-эффекта; базовый вариант возможен только на Flutter.

## Расширения (позже)

- Анимация появления/исчезновения (scale + opacity или slide from anchor).
- Поддержка «якоря» от `RenderBox` кнопки (автоматический расчёт `anchor`).
- `GlassPullDownMenuItem` / темы для пунктов меню в стиле iOS.
