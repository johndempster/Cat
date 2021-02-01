/*
	HelpSmith Web Help System 1.5
	Copyright (c) 2007-2011 Divcom Software
	http://www.helpsmith.com/
*/

function highlightText(bodyText, searchTerm, highlightStartTag, highlightEndTag) {	
	var newText = "";
	var i = -1;
	var lcSearchTerm = searchTerm.toLowerCase();
	var lcBodyText = bodyText.toLowerCase();
    
	while (bodyText.length > 0) {
		i = lcBodyText.indexOf(lcSearchTerm, i + 1);
		if (i < 0) {
			newText += bodyText;
			bodyText = "";
		} 
		else {
			// skip anything inside an HTML tag
			if (bodyText.lastIndexOf(">", i) >= bodyText.lastIndexOf("<", i)) {
				// skip anything inside a <script> block
				if (lcBodyText.lastIndexOf("/script>", i) >= lcBodyText.lastIndexOf("<script", i)) {
					newText += bodyText.substring(0, i) + highlightStartTag + bodyText.substr(i, searchTerm.length) + highlightEndTag;
					bodyText = bodyText.substr(i + searchTerm.length);
					lcBodyText = bodyText.toLowerCase();
					i = -1;
				}
			}
		}
	}
  
	return newText;
}

function highlightSearchTerms(searchDocument, searchText, treatAsPhrase, highlightStartTag, highlightEndTag) {
	if (searchText == '') return false;
	if (treatAsPhrase) {
		var searchArray = [searchText];
	} 
	else {
		var searchArray = splitStrings(searchText);
	}
	
	if (!searchDocument || !searchDocument.body || typeof(searchDocument.body.innerHTML) == "undefined") {
		return false;
	}
	
	var bodyText = searchDocument.body.innerHTML;
	for (var i = 0; i < searchArray.length; i++) {
		bodyText = highlightText(bodyText, searchArray[i], highlightStartTag, highlightEndTag);
	}
	
	searchDocument.body.innerHTML = bodyText;
	return true;
}

function highlight() {
	var words = getParamValue("highlight", get_getQuery());
	if (words != '')
		highlightSearchTerms(document, words, false, "<span style='color: black; background-color: yellow'>", "</span>");
}
