import os
myPath = os.path.abspath(os.path.dirname(__file__))
TEMPLATE_DIRS = [myPath, os.path.join(myPath, 'htmlBUILT'), os.path.join(myPath, 'ewgappengine', 'html'),
'/Applications/GoogleAppEngineLauncher.app/Contents/Resources/GoogleAppEngine-default.bundle/Contents/Resources/google_appengine/google/appengine/ext/admin/templates/']
