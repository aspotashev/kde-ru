/* Copied from http://img.artlebedev.ru/svalka/InputPlaceholder.js on 19.01.2011 */
/*
 *	20.06.2005 17:27
 *	InputPlaceholder Class v 0.1a
 *
 *	30.06.2005 20:36
 *	InputPlaceholder Class v 0.1b
 *
 *	01.07.2005 18:30
 *	InputPlaceholder Class v 0.1c
 */

/*	Методы:
 *		отсутствуют
 *
 *	Свойства
 *		Input			Элемент формы, с которым работаем
 *		Value			Значение надписи по умолчанию
 *		CssFilled		Имя css-класса для отображения заполненого поля
 *		CssEmpty		Имя css-класса для отображения пустого поля
 */

/*	Конструктор
 *	Параметры:
 *		input			Элемент формы ( input[@type='text'] ), с которым работаем
 *		value			Значение надписи по умолчанию, т. е. тот самый placeholder
 *		cssFilled		Имя css-класса для отображения заполненого поля (применяется к input)
 *		cssEmpty		Имя css-класса для отображения пустого поля (применяется к input)
 */
/*
	Я не машина, я просто читаю исходники.
*/
function InputPlaceholder (input, value, cssFilled, cssEmpty)
{
	var thisCopy = this
	
	this.Input = input
	this.Value = value
	this.SaveOriginal = (input.value == value)
	this.CssFilled = cssFilled
	this.CssEmpty = cssEmpty

	this.setupEvent (this.Input, 'focus', function() {return thisCopy.onFocus()})
	this.setupEvent (this.Input, 'blur',  function() {return thisCopy.onBlur()})
	this.setupEvent (this.Input, 'keydown', function() {return thisCopy.onKeyDown()})

	if (input.value == '') this.onBlur();

	return this
}

InputPlaceholder.prototype.setupEvent = function (elem, eventType, handler)
{
	if (elem.attachEvent)
	{
		elem.attachEvent ('on' + eventType, handler)
	}

	if (elem.addEventListener)
	{
		elem.addEventListener (eventType, handler, false)
	}
}

InputPlaceholder.prototype.onFocus = function()
{
	if (!this.SaveOriginal &&  this.Input.value == this.Value)
	{
		this.Input.value = ''
	}
	else
	{
			this.Input.className = ''
	}
}

InputPlaceholder.prototype.onKeyDown = function()
{
	this.Input.className = ''
}

InputPlaceholder.prototype.onBlur = function()
{
	if (this.Input.value == '' || this.Input.value == this.Value)
	{
		this.Input.value = this.Value
		this.Input.className = this.CssEmpty
	}
	else
	{
		this.Input.className = this.CssFilled
	}
}
