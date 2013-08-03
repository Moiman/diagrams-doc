{-# LANGUAGE NoMonomorphismRestriction #-}
{-# LANGUAGE OverloadedStrings         #-}

import           Control.Monad        (forM_, (>=>))
import           Data.Char            (isAlphaNum)
import           Data.Functor         ((<$>))
import           Data.List            (sortBy)
import           Data.Maybe           (fromMaybe)
import           Data.Monoid
import           Data.Ord             (comparing)

import           Data.String

import qualified Data.ByteString.Lazy as LB
import           System.FilePath
import           System.Process       (system)

import           Text.Pandoc

import           Hakyll

pages :: IsString s => [s]
pages = map (fromString . (++".markdown"))
  [ "index"
  , "download"
  , "documentation"
  , "community"
  , "releases"
  ]

main :: IO ()
main = hakyll $ do
    -- CSS, templates, JavaScript -----------------
    match "css/*" $ do
        route   idRoute
        compile compressCssCompiler

    match "templates/*" $ compile templateCompiler

    match "js/*" $ do
        route   idRoute
        compile copyFileCompiler

    -- User manual --------------------------------
    match "doc/*.html" $ do
        route idRoute
        let docCtx = field "title" $ \i -> do
              let baseName = takeBaseName . toFilePath . itemIdentifier $ i
              return $ case baseName of
                "diagrams-manual" -> "User manual"
                "diagrams-quickstart" -> "Quick start tutorial"
                _ -> baseName
        compile (getResourceBody >>= mainCompiler (docCtx <> defaultContext))

    match ("doc/**" .&&. complement "doc/*.html") $ do
        route idRoute
        compile copyFileCompiler

    -- API documentation --------------------------

    match "haddock/**" $ do
        route idRoute
        compile copyFileCompiler

    -- Static images ------------------------------

    match "*.ico" $ do
        route idRoute
        compile copyFileCompiler

    match "images/*" $ do
        route idRoute
        compile copyFileCompiler

    -- Normal .html pages, built from .markdown ---
    forM_ pages $ flip match $ do
        route   $ setExtension "html"
        compile $ pandocCompiler >>= mainCompiler defaultContext

    -- Example gallery ----------------------------

    match "gallery/images/*.png" $ do
        route idRoute
        compile copyFileCompiler

    match "gallery.markdown" $ do
        route $ setExtension "html"

        compile $ do
          galleryContent <- pandocCompiler
          lhss <- loadAll ("gallery/*.lhs" .&&. hasVersion "gallery")
          gallery <- buildGallery galleryContent lhss
          mainCompiler defaultContext gallery

      -- build syntax-highlighted source code for examples
    match "gallery/*.lhs" $ version "gallery" $ do
        route $ setExtension "html"
        compile $ withMathJax
            >>= loadAndApplyTemplate "templates/exampleHi.html"
                  ( mconcat
                    [ setImgURL
                    , setHtmlURL
                    , markdownFieldsCtx ["description"]
                    , defaultContext
                    ]
                  )
            >>= mainCompiler defaultContext

      -- export raw .lhs of examples for download
    match "gallery/*.lhs" $ version "raw" $ do
        route idRoute
        compile getResourceBody

withMathJax :: Compiler (Item String)
withMathJax =
  pandocCompilerWithTransform
    defaultHakyllReaderOptions
    defaultHakyllWriterOptions
    (bottomUp latexToMathJax)
  where latexToMathJax (Math InlineMath str)
          = RawInline "html" ("\\(" ++ str ++ "\\)")
        latexToMathJax (Math DisplayMath str)
          = RawInline "html" ("\\[" ++ str ++ "\\]")
        latexToMathJax x = x

mainCompiler :: Context String -> Item String -> Compiler (Item String)
mainCompiler ctx = loadAndApplyTemplate "templates/default.html" ctx
               >=> relativizeUrls

setThumbURL, setImgURL, setHtmlURL :: Context String
setThumbURL  = setURL "images" "thumb.png"
setImgURL    = setURL "images" "big.png"
setHtmlURL   = setURL "" "html"

setURL :: FilePath -> String -> Context String
setURL dir ext = field (extNm ++ "url") fieldVal
  where extNm = filter isAlphaNum ext
        fieldVal i = do
          u <- fmap (maybe "" toUrl) . getRoute . itemIdentifier $ i
          let (path,f) = splitFileName u
          return (path </> dir </> replaceExtension f ext)

-- | Take the content of the specified fields and make them available
--   after typesetting them as Markdown via pandoc.
markdownFieldsCtx :: [String] -> Context String
markdownFieldsCtx = mconcat . map markdownFieldCtx

markdownFieldCtx :: String -> Context String
markdownFieldCtx f = field f $ \i -> do
  markdown <- fromMaybe "" <$> getMetadataField (itemIdentifier i) f
  return
    . writeHtmlString defaultHakyllWriterOptions
    . readMarkdown defaultHakyllReaderOptions
    $ markdown

buildGallery :: Item String -> [Item String] -> Compiler (Item String)
buildGallery content lhss = do
  -- reverse sort by date (most recent first)
  lhss' <- mapM addDate lhss
  let exs = reverse . map snd . sortBy (comparing fst) $ lhss'

      galleryCtx = mconcat
        [ listField "examples" exampleCtx (return exs)
        , defaultContext
        ]
      exampleCtx = mconcat
        [ setHtmlURL
        , setThumbURL
        , defaultContext
        ]

  loadAndApplyTemplate "templates/gallery.html" galleryCtx content

  where
    addDate lhs = do
      d <- fromMaybe "" <$> getMetadataField (itemIdentifier lhs) "date"
      return (d,lhs)
