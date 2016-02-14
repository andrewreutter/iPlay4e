var EwgCookie = 
{   

	deleteCookie: function( cookieName )
	{	EwgCookie.setCookie( cookieName, '', -1 );
	},
	
	setCookie: function( cookieName, cookieValue, cookieDays )
	{   // Escape the value
        cookieValue = (''+cookieValue).replace(/\,/g, 'cOmMa');
        cookieValue = (''+cookieValue).replace(/\;/g, 'sEmIcOlOn');

		if (cookieDays) {
			var date = new Date();
			date.setTime(date.getTime()+(cookieDays*24*60*60*1000));
			var expires = "; expires="+date.toGMTString();
		}
		else var expires = "";
		var cookieStr = cookieName+"="+cookieValue+expires+"; path=/";
		//window.console.log( 'Setting cookie: ' + cookieStr )
		document.cookie = cookieStr;

        return cookieValue;
	},
	
	getCookie: function(cookieName, defaultValue, defaultCookieDays)
	{
		var nameEQ = cookieName + "=";
		var ca = document.cookie.split(';');
		for(var i=0;i < ca.length;i++) {
			var c = ca[i];
			while (c.charAt(0)==' ') c = c.substring(1,c.length);
			if (c.indexOf(nameEQ) == 0) 
            {   ret = c.substring(nameEQ.length,c.length);
                ret = ret.replace(/cOmMa/g, ',');
                ret = ret.replace(/sEmIcOlOn/g, ';');
                return ret;
            }
		}
        if (defaultValue) return EwgCookie.setCookie(cookieName, defaultValue, defaultCookieDays);
		return '';
	},
	
	getArrayCookie: function(cookieName) 
    {
        cookieStr = EwgCookie.getCookie(cookieName);
        try
        {   return $A(eval(cookieStr));
        }
        catch (e)
        {   return [];
        }
    },

	setArrayCookie: function(cookieName, theArray, cookieDays) 
	{
        var cookieStr = "['";
        for (var i = 0; i < theArray.length; i++)
            cookieStr += ("" + theArray[i] + "','");
        cookieStr = cookieStr.substr(0, cookieStr.length-2) + "]";
        return EwgCookie.setCookie( cookieName, cookieStr, cookieDays||0);
	}
};


