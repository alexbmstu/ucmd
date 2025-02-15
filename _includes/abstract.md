
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

# Разработка микропрограммных устройств управления

**Цель работы:**  Изучение структуры и принципов работы микропрограммных автоматов и получение навыков проектирования микропрограмм. В лабораторной работе используется язык описания и компилятор `UCMD` (ИУ6, МГТУ им Н.Э.Баумана) для реализации устройства распознавания регулярных выражений. В ходе выполнения лабораторной работы необходимо изучить синтаксис языка UCMD и разработать микропрограмму по индивидуальному заданию. Устройство должно быть реализовано на ПЛИС Xilinx Virtex-6 с использованием среды Xilinx ISE 14.7 и отладочной платы Xilinx ML605. 


