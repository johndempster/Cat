﻿/*
	HelpSmith Web Help System 1.5
	Copyright (c) 2007-2011 Divcom Software
	http://www.helpsmith.com/
*/

function synctoc(link) {
	if (top.window && top.window.tocTree &&
		(!top.window.tocTree.selectedNode || (removeBookmark(top.window.tocTree.selectedNode.link) != link))) {
		var navFrame = findFrame('navigation');
		if (navFrame) {
			var href = extractFileName(navFrame.location.href);
			if (href == whFrameHrefs.toc) {
				top.window.tocTree.selectNodeByLink(link, true, true);
			}
		}
	
	}
}
