<style>

/* By default, make all images center-aligned, and 60% of the width
of the screen in size */
img
{
    display:block;
    float:none;
    margin-left:auto;
    margin-right:auto;
    width:90%;
}

/* Create a CSS class to style images to 90% */
.fullPic
{
    display:block;
    float:none;
    margin-left:auto;
    margin-right:auto;
    width:100%;
}

/* Create a CSS class to style images to 60% */
.normalPic
{
    display:block;
    float:none;
    margin-left:auto;
    margin-right:auto;
    width:60%;
}

/* Create a CSS class to style images to 40% */
.thinPic
{
    display:block;
    float:none;
    margin-left:auto;
    margin-right:auto;
    width:40%;
}

/* Create a CSS class to style images to 20% */
.smallPic
{
    display:inline-block;
    float:left;
    margin-left:none;
    margin-right:none;
    width:150px;
}

/* Create a CSS class to style images to left-align, or "float left" */
.leftAlign
{
    display:inline-block;
    float:left;
    /* provide a 15 pixel gap between the image and the text to its right */
    margin-right:15px;
}

/* Create a CSS class to style images to right-align, or "float right" */
.rightAlign
{
    display:inline-block;
    float:right;
    /* provide a 15 pixel gap between the image and the text to its left */
    margin-left:15px;
}
.image-caption {
  text-align: center;
  font-size: 1.0rem;
}

</style>


## 3. Требования к отчету

Отчёт должен содержать:

* Цель работы.
* Задание.
* Verilog-код модулей части 1.
* Код микропрограммы `"Hello world!"`.
* Диаграмма переходов состояний автомата `"Hello world!"`.
* Результаты работы устройства части 1 (копия экрана консоли).
* Индивидуальное задание части 2.
* Verilog-код модулей части 2.
* Код микропрограммы распознавания регулярного выражения.
* Диаграмма переходов состояний автомата распознавания регулярного выражения.
* Результаты тестирования устройства части 2 (копия экрана консоли).
* Выводы.

## 4. Контрольные вопросы

1. Что такое микропрограммный автомат? Объясните его структуру и основные компоненты.
2. Чем отличается микропрограммное управление от жесткой логики? Приведите преимущества и недостатки каждого подхода.
3. Что такое микрокоманда и микропрограмма? Опишите их роль в работе микропрограммного автомата.
4. Какие типы микропрограммных автоматов вы знаете? Опишите различия между автоматами Мили и Мура.
5. Как работает управляющий автомат с микропрограммным управлением? Опишите его основные функции и принцип работы.
6. Составьте микропрограмму для выполнения простой операции (например, сложения двух чисел). Опишите, как будет выглядеть набор микрокоманд.
7. Как кодируются микрокоманды в микропрограммном автомате? Приведите пример кодировки для конкретной операции.
8. Разработайте схему микропрограммного автомата для управления простым устройством (например, светофором). Опишите, как будут формироваться управляющие сигналы.
9. Как реализуется переход между состояниями в микропрограммном автомате? Опишите, как формируются сигналы перехода и как они влияют на выполнение микропрограммы.
