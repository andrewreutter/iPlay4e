#!/usr/bin/env python
import os, time, re, sys

# CLASSES

class TokensReplacer:
    """ A callable that replaces all necessary tokens in a string.
    """
    def __init__(self):
        self.__regexPairs = []
    def addTokenSet(self, oldPattern, newText):
        self.__regexPairs.append((re.compile(oldPattern), newText))
    def __call__(self, stringToProcess):
        applyTokenSet = lambda ret, (oldRegex, newText): oldRegex.sub(newText, ret)
        return reduce(applyTokenSet, self.__regexPairs, stringToProcess)

class Maker:
    PATH_SEPARATOR = {':':'/'}.get(os.pathsep, os.pathsep)

    STATIC_SOURCE_DIR = 'src'
    STATIC_OUTPUT_DIR = 'BUILTsrc'
    IN_PLACE_TOKEN_FILES = ('app.yaml', 'ewgappengine/db.py')

    COMBO_SOURCES_AND_FILES = \
    (   
        (   (   
                ('js', 'prototype', 'prototype.js'),
                ('js', 'scriptaculous', 'src', 'effects.js'),
                ('js', 'lightbox.js'),
                ('js', 'EwgCookies.js'),
                ('js', 'iplay4e.js'),
                ('js', 'custom.js'),
            ), 
            ('js', 'combo.js')
        ),
        (   (   
                ('css', 'blueprint', 'screen.css'),
                ('css', 'blueprint', 'plugins', 'buttons', 'screen.css'),
                ('css', 'lightbox.css'),
                ('css', 'iplay4e.css'),
                ('css', 'sheets.css'),
            ), 
            ('css', 'combo.css')
        ),
    )

    BAD_DIRS = \
    (   '.svn', 
        'scriptaculous/test', 
        'blueprint/plugins/fancy-type',
        'blueprint/plugins/link-icons',
        'blueprint/plugins/rtl',
        'blueprint/src',
    )
    BAD_FILES = ('CHANGELOG', 'MIT-LICENSE', 'README.rdoc', 'swp')

    def __init__(self):
        self.setMinified(True)

        timeToken = str(time.time()).replace('.', '')

        self.REPLACE_TOKENS = TokensReplacer()
        self.REPLACE_TOKENS.addTokenSet('url: \/[0-9]*\/', 'url: /%s/' % timeToken)
        self.REPLACE_TOKENS.addTokenSet('TIME_TOKEN', timeToken)

    def setMinified(self, isMinified):
        self.__isMinified = isMinified
        return self

    # MAIN MAKE ROUTINE AND DISCRETE STEPS

    def make(self):
        self.__cleanup()
        self.__copyStaticReplacingTokens()
        self.__copyOtherReplacingTokens()
        self.__createComboFiles()
        if self.__isMinified:
            self.__minifyComboFiles()

    def __cleanup(self):
        self.__systemCall('rm -rf %s' % self.STATIC_OUTPUT_DIR)

    def __copyStaticReplacingTokens(self):
        for newDirPath, oldNewFileTuples in self.__walkStaticDirs():
            self.__systemCall('mkdir -p %s' % newDirPath)
            [ self.__copyFileReplacingTokens(oldFilename, newFilename) for oldFilename, newFilename in oldNewFileTuples ]

    def __copyOtherReplacingTokens(self):
        [ self.__copyFileReplacingTokens(thisFilename, thisFilename) for thisFilename in self.IN_PLACE_TOKEN_FILES ]

    def __createComboFiles(self):
        for sourceFileTuples, comboFileTuple in self.COMBO_SOURCES_AND_FILES:
            sourceFileTuples = [ (self.STATIC_OUTPUT_DIR,) + sourceFileTuple for sourceFileTuple in sourceFileTuples ]
            comboFileTuple = (self.STATIC_OUTPUT_DIR,) + comboFileTuple
            
            sourceFilePaths = ' '.join([ os.path.join(*sourceFileTuple) for sourceFileTuple in sourceFileTuples ])
            comboFilePath = os.path.join(*comboFileTuple)
            self.__systemCall('cat %(sourceFilePaths)s > %(comboFilePath)s' % locals())

    def __minifyComboFiles(self):
        for garbage, comboFileTuple in self.COMBO_SOURCES_AND_FILES:
            comboFileTuple = (self.STATIC_OUTPUT_DIR,) + comboFileTuple

            comboFilePath = os.path.join(*comboFileTuple)
            comboFilePathAndExt = os.path.splitext(comboFilePath)
            tempFilePath = '%s.TEMP.%s' % comboFilePathAndExt

            self.__systemCall("""cat %(comboFilePath)s > %(tempFilePath)s""" % locals())
            self.__systemCall("""java -jar yuicompressor-2.4.2.jar %(tempFilePath)s > %(comboFilePath)s""" % locals())
            self.__systemCall("""rm %(tempFilePath)s""" % locals())

    # HELPER METHODS

    def __systemCall(self, callString):
        #print callString
        return os.system(callString)

    def __copyFileReplacingTokens(self, oldFilename, newFilename):
        theFile = open(oldFilename, 'rb')
        content = self.REPLACE_TOKENS(theFile.read())
        theFile.close()
        open(newFilename, 'wb').write(content)

    def __walkStaticDirs(self):
        """
        @return: list of 2-tuples: (newDirPath, [(oldFilename, newFilename), ...])
        """

        ret = []
        for oldSubdir, dirs, fileNames in [ ow for ow in os.walk(self.STATIC_SOURCE_DIR) if not self.__skipSubdir(ow[0]) ]:
        
            subdirPieces = oldSubdir.split(self.PATH_SEPARATOR)
            newSubdirPieces = [self.STATIC_OUTPUT_DIR] + subdirPieces[1:] # replace e.g.: src with BUILTsrc
            newSubdir = os.path.join(*newSubdirPieces)
        
            fileTuples = []
            for thisFile in [ fn for fn in fileNames if not self.__skipFile(fn) ]:
                fileTuples.append([ os.path.join(thisDir, thisFile) for thisDir in (oldSubdir, newSubdir) ])

            ret.append((newSubdir, fileTuples))
        return ret

    def __skipSubdir(self, subDir):
        for badDir in self.BAD_DIRS:
            if subDir.find(badDir) != -1:
                return 1

    def __skipFile(self, fileName):
        for badName in self.BAD_FILES:
            if fileName.find(badName) != -1:
                return 1

# MAIN

def main():
    theMaker = Maker()
    if len(sys.argv) > 1 and sys.argv[1] == '0':
        theMaker.setMinified(False)
    theMaker.make()

(__name__ == '__main__') and main()
