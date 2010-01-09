// misc HTML functions

// set a cookie

function setCookie(name, value, expire)
{
  document.cookie = name + "=" + escape(value) +
    ((expire == null) ? "" : ("; expires=" + expire.toUTCString()));
}


// get a cookie

function getCookie(Name)
{
  var search = Name + "=";

  if (document.cookie.length == 0) return null;

  var offset = document.cookie.indexOf(search);

  if (offset == -1) return null;

  offset += search.length;

  // set index of beginning of value
  end = document.cookie.indexOf(";", offset);

  // set index of end of cookie value
  if (end == -1)
    end = document.cookie.length;

  return unescape(document.cookie.substring(offset, end))
}
											     