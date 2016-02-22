/*
	HelpSmith Web Help System 1.5
	Copyright (c) 2007-2011 Divcom Software
	http://www.helpsmith.com/
*/

function findFuncResuls(index, found) {	
	this.index = index;
	this.found = found;
}

function searchResult() {
	this.items = [];
	this.find = searchResult_find;
	this.addItem = searchResult_addItem;
}

function searchResult_find(topicDataIndex) {
	var found = false;	
	var l = 0;
	var h = this.items.length - 1;
	var i, c;
	while (l <= h) {
		i = (l + h) >> 1;
		c = (this.items[i].topicDataIndex - topicDataIndex);
		if (c < 0) {
			l = i + 1;
		}
		else {
			h = i - 1;
			if (c == 0) {
				found = true;
				l = i;
			}
		}
	}	
	return new findFuncResuls(l, found);
}

function searchResult_addItem(topicDataIndex) {
	var r = this.find(topicDataIndex);	
	if (!r.found) {
		this.items.splice(r.index, 0, new searchResultItem(topicDataIndex));
	}	
	return r.index;
}

function searchResultItem(topicDataIndex) {
	this.topicDataIndex = topicDataIndex;	
	this.words = [];
	this.getTitle = function () {
		return gTopicInfo[this.topicDataIndex][0];
	};
	this.getTopicRef = searchResultItem_getTopicRef;
	this.find = searchResultItem_find;
	this.addWord = searchResultItem_addWord;
}

function searchResultItem_getTopicRef(wordsParamName) {
	var ref = gTopicInfo[this.topicDataIndex][1];
	if (wordsParamName) {
		var s = "";
		for (var i = 0; i < this.words.length; i++) {
			s += this.words[i];
			if (i < this.words.length - 1) {
				s += " ";
			}
		}
		ref += "?" + wordsParamName + "=" + escape(s);
	}
	return ref;
}

function searchResultItem_find(word) {
	var found = false;
	var l = 0;
	var h = this.words.length - 1;
	var i, c;
	while (l <= h) {
		i = (l + h) >> 1;
		c = compareStrings(this.words[i], word);
		if (c < 0) {
			l = i + 1;
		}
		else {
			h = i - 1;
			if (c == 0) {
				found = true;
				l = i;
			}
		}
	}	
	return new findFuncResuls(l, found);
}

function searchResultItem_addWord(word) {
	var r = this.find(word);	
	if (!r.found) {
		this.words.splice(r.index, 0, word);
	}	
	return r.index;
}

function lookupAlphaIndex(ch) {
	ch = ch.toLowerCase();
	for (var i = 0; i < gAlphaIndex.length; i++) {
		if (ch == gAlphaIndex[i][0]) {
			return i;
		}
	}
	return -1;
}

function addWordDataToSearchResult(searchResult, wordData) {
	// wordData is an array
	// 0: word
	// 1: array of topic data indexes
	for (var i = 0; i < wordData[1].length; i++) {
		var index = searchResult.addItem(wordData[1][i]);
		searchResult.items[index].addWord(wordData[0]);
	}
}

function findByWord(searchResult, word) {
	if (word.length == 0 || word.length < whSearch.MinWordLength) return;	
	
	var index = lookupAlphaIndex(word.charAt(0));
	if (index < 0) return;
	
	var start = gAlphaIndex[index][1];
	var end = gAlphaIndex[index][2];
	if (start > end) return;
	
	var lcWord = word.toLowerCase();
	for (var i = start; i <= end; i++) {		
		var subStr = gWordList[i][0].substr(0, lcWord.length);	
		if (subStr == lcWord) {
			addWordDataToSearchResult(searchResult, gWordList[i]);			
		}
	}	
}

function search(query) {
	var sr = new searchResult();
	
	var q = splitStrings(query);
	if (q.length == 0) return sr;
	
	for (var i = 0; i < q.length; i++) {
		findByWord(sr, q[i]);
	}	
	return sr;	
}

function sortSearchResult(searchResult) {

	function getItemPos(list, title) {
		var l = 0;
		var h = list.length - 1;
		var i, c;
		while (l <= h) {
			i = (l + h) >> 1;
			c = compareStrings(list[i].getTitle(), title);
			if (c < 0) {
				l = i + 1;
			}
			else {
				h = i - 1;
			}
		}
		return l;
	}

	if (!searchResult) return null;
	var list = [];
	for (var i = 0; i < searchResult.items.length; i++) {
		var item = searchResult.items[i];
		var index = getItemPos(list, item.getTitle());
		list.splice(index, 0, item);
	}
	return list;
}

function searchAndFill(query, select) {
	select.length = 0;
	var searchResult = search(query);
	if (searchResult.items.length == 0) {
		alert(whTextLabels.NoTopicsFoundMsg);
	}
	else {
		var sortedList = sortSearchResult(searchResult);		
		for (var i = 0; i < sortedList.length; i++) {			
			var item = sortedList[i];			
			var o = document.createElement("option");
			o.text = item.getTitle();
			o.value = item.getTopicRef("highlight");
			select[select.length] = o;
		}
	}
}

function openTopicFromSelect(select) {
	open(select.options[select.selectedIndex].value, 'topic');
}
