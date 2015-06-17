var delay;
var url;
var img;

function main()
{
    var imgLink = document.getElementById("imgLink");
    var nextLink = document.getElementById("nextLink");
    nextLink.href = imgLink.href;
    img = document.getElementById("mainImg");
    url = imgLink.href;
    imgLink.href = img.src;
    
    resizer();
    setTimeout('delayer()', delay);
}

function resizer()
{
    var wRatio = (window.innerWidth * 0.8) / (window.innerHeight * 0.91);
    var iRatio = img.width / img.height;
    if (iRatio > wRatio)
    {
        img.setAttribute("width", "100%");
    }
    else
    {
        img.setAttribute("height", "91%");
    }
    var ext = img.src.substr(-3, 3);
    if (ext == "gif")
    {
        delay = 15000;
    }
    else
    {
        delay = 8000;
    }
}

function delayer()
{
    window.location = url;
}