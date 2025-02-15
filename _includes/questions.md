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
* Verilog-код модулей.
* Результаты моделирования.
* Результаты статического временного анализа.
* Результаты исследования масимальной тактовой частоты для каждого варианта сумматора.
* График зависимости максимальной частоты устройства от количества стадий конвейера. 
* Выводы.


## 4. Контрольные вопросы

* Что такое конвейеризация и какие её преимущества?
* В чём разница между RCA, CLA и CSA?
* Как  осуществляется  конвейеризация  многоразрядного  сумматора?
* Как  оценивается  производительность  конвейерного  сумматора?
* Какие  ресурсы  ПЛИС  используются  при  реализации  различных  архитектур  сумматоров?
* Какое количество триггеров необходимо дополнительно использовать при 2-х стадийной конвейеризации 128-битного сумматора? 

 
