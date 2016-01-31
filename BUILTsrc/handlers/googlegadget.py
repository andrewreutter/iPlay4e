from google.appengine.api import users

from IP4ELibs import models, BaseHandler

class MainHandler(BaseHandler.BaseHandler):

    def get(self):
        hostName = self.request.host
        key = self.request.get('key')

        gadgetXML = """\
<?xml version="1.0" encoding="UTF-8" ?>
<Module>
    <ModulePrefs 
     title="iPlay4e"
     title_url="http://iplay4e.com"
     description="Character hosted by iplay4e" 
     author="Andrew Reutter"
     author_email="andrew.reutter+iplay4e@gmail.com"
     height="460"
     scaling="false" 
     scrolling="true"
    >
        <Icon>http://%(hostName)s/favicon.ico</Icon>
        <Require feature="dynamic-height"/>
    </ModulePrefs>
    <Content type="html">
        <![CDATA[
            <script type="text/javascript">
                var onmessage = function(e) 
                {
                    if (e.origin.search('iplay4e.appspot.com') == -1) return;
                    document.getElementById('iContent').style.height = e.data + 'px';
                    gadgets.window.adjustHeight();
                }; 
                     
                if (typeof window.addEventListener != 'undefined') { 
                  window.addEventListener('message', onmessage, false); 
                } else if (typeof window.attachEvent != 'undefined') { 
                  window.attachEvent('onmessage', onmessage); 
                }
            </script>
            <iframe src="http://%(hostName)s/view?xsl=fullold&amp;key=%(key)s" 
             id="iContent" width="970" height="645"></iframe>
        ]]>
    </Content>
    <Content type="url"
     view="home,profile"
     href="http://%(hostName)s/view?xsl=jPint&amp;key=%(key)s"
     preferred_height="460"
     preferred_width="335"
    />
</Module>""" % locals()

        self.response.headers['Content-Type'] = 'text/xml'
        self.response.out.write(gadgetXML)
