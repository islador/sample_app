//# Place all the behaviors and hooks related to the matching controller here.
//# All this logic will automatically be available in application.js.
//# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

//# `wrap found/preexisting javascript in back ticks`
//# http://coffeescriptcookbook.com/chapters/syntax/embedding_javascript

var count = 0;
function countChar()
{
	count = document.getElementById("micropost_content").value.length;
	document.getElementById("counter").innerHTML=count + '/140';
	if (count >= 141)
	{
		document.getElementById("counter").innerHTML="Character Limit Exceeded";
		document.getElementById("counter").style.color='Red';
	} else
	{
		document.getElementById("counter").style.color='Black';
	}
}