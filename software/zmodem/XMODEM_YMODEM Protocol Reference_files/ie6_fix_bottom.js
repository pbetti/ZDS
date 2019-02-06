//
// ie6_fix_bottom
//
// This script will correct issues with CSS support where pages are set
// to a given width and centered.  This code would be executed immediately
// before the </body> tag.
//

if (navigator.appName == 'Microsoft Internet Explorer')
{
    msieStringLoc = navigator.userAgent.indexOf("MSIE");
    if (msieStringLoc != -1)
    {
        msieVersion = parseFloat(navigator.userAgent.substring(msieStringLoc+5));
        if (msieVersion < 7)
        {
            document.writeln("</td></tr></table></center>");
        }
    }
}
