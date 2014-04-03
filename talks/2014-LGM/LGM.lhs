%% -*- mode: LaTeX; compile-command: "mk" -*-
\documentclass[xcolor=svgnames,12pt]{beamer}

%include lhs2TeX.fmt

% \usepackage{brent}
\usepackage[backend=cairo,extension=pdf,outputdir=diagrams]{diagrams-latex}
\graphicspath{{images/}}
\usepackage{ulem}

% \setbeamertemplate{footline}{\insertframenumber}

\setbeamertemplate{items}[circle]

\mode<presentation>
{
  \usetheme{default}                          % use a default (plain) theme

  \setbeamertemplate{navigation symbols}{}    % don't show navigation
                                              % buttons along the
                                              % bottom
  \setbeamerfont{normal text}{family=\sffamily}

  % XX remove this before giving actual talk!
  % \setbeamertemplate{footline}[frame number]
  % {%
  %   \begin{beamercolorbox}{section in head/foot}
  %     \vskip2pt
  %     \hfill \insertframenumber
  %     \vskip2pt
  %   \end{beamercolorbox}
  % }

  \AtBeginSection[]
  {
    \begin{frame}<beamer>
      \frametitle{}

      \begin{center}
        % \includegraphics[width=1in]{\sectionimg}
        % \bigskip

        {\Huge \insertsectionhead}
      \end{center}
    \end{frame}
  }
}

\defbeamertemplate*{title page}{customized}[1][]
{
  \vbox{}
  \vfill
  \begin{centering}
    \begin{beamercolorbox}[sep=8pt,center,#1]{title}
      \usebeamerfont{title}\inserttitle\par%
      \ifx\insertsubtitle\@@empty%
      \else%
        \vskip0.25em%
        {\usebeamerfont{subtitle}\usebeamercolor[fg]{subtitle}\insertsubtitle\par}%
      \fi%
    \end{beamercolorbox}%
    \vskip1em\par
    {\usebeamercolor[fg]{titlegraphic}\inserttitlegraphic\par}
    \vskip1em\par
    \begin{beamercolorbox}[sep=8pt,center,#1]{author}
      \usebeamerfont{author}\insertauthor
    \end{beamercolorbox}
    \begin{beamercolorbox}[sep=8pt,center,#1]{institute}
      \usebeamerfont{institute}\insertinstitute
    \end{beamercolorbox}
    \begin{beamercolorbox}[sep=8pt,center,#1]{date}
      \usebeamerfont{date}\insertdate
    \end{beamercolorbox}
  \end{centering}
  \vfill
}

\newenvironment{xframe}[1][]
  {\begin{frame}[fragile,environment=xframe,#1]}
  {\end{frame}}

% uncomment me to get 4 slides per page for printing
% \usepackage{pgfpages}
% \pgfpagesuselayout{4 on 1}[uspaper, border shrink=5mm]

% \setbeameroption{show only notes}

\renewcommand{\emph}{\textbf}

\title{Declarative, Programmatic Vector Graphics in Haskell}
\date{Libre Graphics Meeting \\ Leipzig, Germany \\ 3 April, 2013}
\author{Brent Yorgey}
% \titlegraphic{\includegraphics[width=1in]{Factorization.png}}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\begin{document}

\begin{xframe}
  \titlepage
\end{xframe}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Diagrams (http://projects.haskell.org/diagrams) is a powerful
% domain-specific language, embedded in the Haskell programming
% language, for creating vector graphics and animations. I will show
% some examples of what is possible using the framework, particularly
% illustrating the benefits and power of Haskell as a substrate for a
% graphics language. I will talk briefly about the community
% surrounding its development, and explain some of the current
% features in development as well as our longer-term goals for the
% project.

% Brainstorming:
%   Start with very short "what is it".
%     - declarative, embedded in Haskell, many backends
%   Examples---visual + code.
%   Briefly mention community --- active contributors, successful GSoC projects
%   Features/approaches: very mathematical approach.  *Semantics*?
%     E.g. paths.  animations.
%   Where we are going:
%     + editing operations
%     + GUI --- interactive, bidirectional?
%     + animations & interactivity

%% Diagrams.
%% [All graphics in this talk were produced using diagrams!]

\begin{xframe}

  %%% This talk is about diagrams, a
  %%% domain-specific language for producing vector
  %%% graphics. Intended to be higher-level than e.g. cairo but still
  %%% general-purpose. Make it easy to build special-purpose
  %%% visualizations on top of it."

  %%% Note I am a PL person who loves to think and communicate
  %%% visually.  I don't know a lot about graphics (but I am
  %%% learning!).  So I would welcome feedback and collaboration.

  \begin{overprint}
  \onslide<1>
  \begin{center}
  \begin{diagram}[width=300]
    import LGMDiagrams
    import Diagrams.Example.Logo

    dia = mkDiagrams ico_d
  \end{diagram}
  \end{center}

  %%% One of the most interesting things about it is that it is
  %%% *embedded* in Haskell.  By "embedded" I mean that diagrams is
  %%% "just" a Haskell library, with the feel of a separate language.

  \onslide<2>
  \begin{center}
  \begin{diagram}[width=300]
    import LGMDiagrams
    import Diagrams.Example.Logo

    dia = mkDiagrams
      ( ico_d # centerXY
        <>
        image "images/haskell-logo-light.png" 7 7
          # withEnvelope (square 6 :: D R2)
      )
  \end{diagram}
  \end{center}
  \end{overprint}
  \bigskip

  \begin{overprint}
  \onslide<2>
  \begin{center}
  \textit{Embedded} in Haskell.
  \end{center}
  \end{overprint}
\end{xframe}

%%% Here's a simple example of what you can do.  Make a circle and a
%%% square, give them some coordinates, put them next to each other.
%%% Note this is really a Haskell expression!
%%%
%%% Worth pointing out one feature: we don't need coordinates.  This
%%% is a design goal.  Should be able to work in relative and
%%% scale-invariant ways.

\begin{xframe}
  \begin{center}
  \begin{diagram}[width=100]
    dia = hcat [circle 1 # fc green, square 2 # fc blue] # frame 0.2
  \end{diagram}
   \bigskip

  \begin{spec}
    circle 1 # fc green ||| square 2 # fc blue
  \end{spec}

  \onslide<2>{\textit{Look ma, no coordinates!}}
  \end{center}
\end{xframe}

%%% Here's a more complex example.  Understanding the code is not the
%%% point.  Note that this is just a Haskell program; Haskell is
%%% general-purpose so we get to use it, e.g. to compute the tree we
%%% want to draw.  Can combine data processing and visualization into
%%% a single program.

\begin{xframe}
  \begin{center}
  \begin{diagram}[width=200]
    import Diagrams.TwoD.Layout.Tree
    import Data.List (transpose)
    import Data.Maybe (fromJust)
    import Data.Colour.Palette.BrewerSet

    fibCalls :: Int -> BTree Int
    fibCalls 0 = leaf 0; fibCalls 1 = leaf 1
    fibCalls n = BNode n (fibCalls (n-1)) (fibCalls (n-2))

    colorsBS = brewerSet PuBuGn 9 # reverse # drop 2
    colors = concat (transpose [colorsBS, blends])
      where blends = zipWith (blend 0.5) colorsBS (tail colorsBS)

    tree = renderTree'
             (\i -> circle 0.3 # lw 0 # fc (colors !! i))
             (\(i,p) (_,q) -> p ~~ q # lw 0.03 # lc (colors !! i))
         . fromJust . symmLayoutBin . fibCalls $ 8
    dia = tree # centerXY # frame 1
  \end{diagram}
  \begin{spec}
fib 0 = leaf 0; fib 1 = leaf 1
fib n = BNode n (fib (n-1)) (fib (n-2))

tree
  = renderTree'
      (\i -> circle 0.3 # lw 0 # fc (colors !! i))
      (\(i,p) (_,q) -> p ~~ q # lc (colors !! i))
  . fromJust . symmLayoutBin . fib
  $ 8
  \end{spec}
  \end{center}
\end{xframe}

%%% So let me tell you a little bit about Haskell, and in particular
%%% why Haskell makes a great host language for EDSLs.  Here are some
%%% of the most important reasons (though there are certainly others).
%%% I'll give some examples from diagrams to illustrate each point.

\begin{xframe}{Haskell and EDSLs}
  Haskell makes a great host language for DSLs:
  \begin{itemize}
  \item strong static type system
  \item first-class functions
%  \item clean syntax
  \item powerful abstraction mechanisms
  \item culture that encourages elegant, mathematically-based design:
    theory meets practice
  \end{itemize}
\end{xframe}

%%% XXX write up what I should say!

\begin{xframe}{Types}
  \begin{center}
    Haskell has a \emph{strong static type system}. \medskip

  points
  \begin{tabular}{@@{}c@@{}}
  \begin{diagram}[width=10]
    dia = circle 1 # fc black # lw 0
  \end{diagram}
  \end{tabular}
  \medskip

  vectors
  \begin{tabular}{@@{}c@@{}}
  \begin{diagram}[width=30]
    dia = arrow 2 # rotateBy (1/10) # lw 0.03 # frame 0.2
  \end{diagram}
  \end{tabular}
  \medskip

  colors
  \begin{tabular}{@@{}c@@{}}
  \begin{diagram}[width=30]
    dia = square 1 # lw 0 # fc red
  \end{diagram}
  \end{tabular}
  \medskip

  paths
  \begin{tabular}{@@{}c@@{}}
  \begin{diagram}[width=50]
    dia = cubicSpline False [origin, 2 ^& 2, 3 ^& 1, (-0.5) ^& 1, 2 ^& (-1)]
        # lw 0.05 # frame 0.5
  \end{diagram}
  \end{tabular}
  \medskip

  Impossible to make silly mistakes like applying a vector to a color,
  or adding two points.

  \end{center}
\end{xframe}

%%% XXX write up what I should say

\begin{xframe}{Functions}
  \begin{center}
    Haskell has \emph{first-class functions}.
    \vfill
    \begin{diagram}[width=250]
mkP d = d <> square 5 # lw 0.01 # dashing [0.1,0.1] 0
mkD d = d <> square 5

sepLine v d = p1 ~~ p2
  where
      b  = envelopeP v d
      v' = normalized v
      p1 = b .+^ (rotateBy (1/4) v')
      p2 = b .+^ (rotateBy (-1/4) v')

illustrateEnvelope v d
  = mconcat
    [ origin ~~ (origin .+^ v)
      # lc black # lw 0.03
    , polygon (with & polyType  .~ PolyRegular 3 0.1
                    & polyOrient .~ OrientTo (negateV v)
              )
      # fc black
      # translate v
    , sepLine v d
      # lc blue # lw 0.02
    , origin ~~ envelopeP v d
      # lc green # lw 0.05
    ]

withEnv :: Diagram Cairo R2 -> R2 -> Diagram Cairo R2
withEnv d v = illustrateEnvelope v d <> d # showOrigin

d1 = circle 1 # scaleX 2 # translate (r2 (0.5, 0.5))

d2 = square 1.5 # translate ((-1) ^& (-1.5))

dia = hcat [
      (d1 # showOrigin <>
       illustrateEnvelope (r2 (0.5,0.3)) (d1 :: D R2) <>
       illustrateEnvelope (0.5 *^ unitY) (d1 :: D R2)
      ) # centerY
      , strutX 2
      , (d2 # showOrigin' (with & oMinSize .~ 0.08) <>
          illustrateEnvelope (normalized (3 ^& 2)) (d2 :: D R2) <>
          illustrateEnvelope (fromDirection (13/20 @@@@ turn)) (d2 :: D R2)
        ) # centerY
      ]
    # centerXY # pad 1.1
    \end{diagram}
  \end{center}
\end{xframe}

% \begin{xframe}{Syntax}
%   XXX do I want to include this?
% \end{xframe}

%%% XXX write up what I should say.

\begin{xframe}{Abstraction}
  \begin{center}
    Haskell has \emph{powerful abstraction mechanisms}. \medskip

    \begin{overprint}
    \onslide<2>
    \begin{center}
    \begin{diagram}[width=75]
      dia = square 1 # frame 0.2
    \end{diagram}

    \begin{spec}
         square :: Double -> Diagram
    \end{spec}
    \end{center}

    \onslide<3>
    \begin{center}
    \begin{diagram}[width=250]
      {-# LANGUAGE TypeFamilies #-}
      hsep :: (Monoid' a, Juxtaposable a, HasOrigin a, V a ~ R2) => Double -> [a] -> a
      hsep n = hcat' (with & sep .~ n)

      dot = circle 0.2 # fc blue # lw 0

      dia = hsep 1 [ square 1
                   , (square 1 <> square 1 # reversePath # rotateBy (1/7))
                     # stroke # fc red
                   , square 1 # map (place dot) # mconcat
                   ]
        # frame 0.2
    \end{diagram}
    \end{center}

    \begin{spec}
square :: (TrailLike t, Transformable t, V t ~ R2)
       => Double -> t
    \end{spec}
    \end{overprint}
  \end{center}
\end{xframe}

\begin{xframe}{Denotational design}
  \begin{overprint}
  \onslide<1>
  \begin{center}
    \vspace{0.3in}
    Haskell encourages \emph{elegant, mathematically-based design}. \medskip

    \begin{diagram}[width=200]
      {-# LANGUAGE FlexibleInstances #-}

      eqn vis a b = hcat' (with & sep .~ 1) [vis a, text "+", vis b, text "=" # named "ctr", vis (a `mappend` b)]
        # withName "ctr" (\sub -> translate (origin .-. location sub))

      newtype Next a = Next { getNext :: a }
      instance Monoid (Next (Diagram B R2)) where
        mempty = Next mempty
        (Next a) `mappend` (Next b) = Next (a |||||| b)

      c = circle 0.5 # fc blue
      s = square 1 # fc yellow

      dia = vcat' (with & sep .~ 1)
        [ eqn id c s
        , eqn getNext (Next c) (Next s)
        , eqn (\c -> square 0.8 # lw 0 # fc c) red blue
        , eqn (lw 0.03 . centerXY . strokeT)
            (fromOffsets [unitX, unitY])
            (fromOffsets [1 ^& (-1), 1 ^& 1])
        , eqn (\t -> transform t (text "F" <> square 1 # lw 0)) (scalingX 3) (rotation (20 @@@@ deg))
        ]
    \end{diagram}
  \end{center}

  \onslide<2>
  \begin{center}
  \includegraphics[width=2.5in]{monoid-pearl-page1}
  \end{center}
  \end{overprint}
\end{xframe}

\begin{xframe}{Examples}
  \begin{center}
    \includegraphics[width=3.5in]{gallery}
  \end{center}
\end{xframe}

\begin{xframe}{Examples}
  \begin{center}
    \includegraphics[width=3in]{parking}
  \end{center}
\end{xframe}

%% Examples! (most with code)

%%% decide on some actual examples to include: each one should
%%% probably illustrate some particular feature

%%% arrow from one thing to another.
%%% Fibonacci call tree.
%%% Sunflower
%%% unix poster?
%%% charts generated with Chart?
%%% parking diagram --- embedded.

%%% other features---animation

%%% things to mention/illustrate:
%%%% example showing why it's nice having it embedded.
%%%% mathematical approach. semantics.
%%%% animation??
%%%% ???

% \begin{xframe}{Diagrams and LGM}
%   \begin{diagram}[width=100]
%     import Data.Colour.SRGB
%     import Diagrams.Example.Logo

%     lgm = iterate (/1.2) 1 # take 3
%         # map (rotate (15 @@@@ deg) . alignBL . square)
%         # hcat' (with & catMethod .~ Distrib
%                       & sep .~ (1/1.2) / cos (15 * pi / 180) - 0.01)
%         # lw 0 # fc (sRGB24 0 0 0x7e)
%     -- 94 px, 15.36
%     -- 78.x px, 15 deg
%     -- 65 px, 15 deg
%     -- 1.2 scaling factor.

%     -- 82 px bewteen bottom corners.  Basically should be
%     -- middle square length / cos 15.

%     -- color is 0x00007e.

%     dia = hcat [logo, lgm # scale 10]
%   \end{diagram}
% \end{xframe}

%% LGM

%%% How does diagrams fit here?  Has things to learn and to offer.

%%% I would love to get feedback from people who actually know things
%%% about graphics!  I am enthusiastic and like communicating
%%% visually, but don't actually know a lot about the area.

%%% Domain-specific languages.  Capture inherent semantics of a
%%% domain.

% \begin{xframe}{Community}
%   %% Graph of unique nicks in IRC channel??  Nah, don't have enough
%   %% data for that.

%   %%% Strong community.  Successful GSoC projects (two last year, one or
%   %%% more this year?)

%   Community.
% \end{xframe}

% \begin{xframe}{History}
%   \begin{center}
%     %% TODO (if time, e.g. on plane)
%     %%% maybe try using Chart instead?!
%     %%% add another graph showing total LOC (use Chart)
%     %%% add colors for contributors!!
%     %%% scale vertically to maximize slide space usage
%     %%% add vertical lines with years marked
%     \includegraphics[width=3in]{RepoRainbow}
%   \end{center}
% \end{xframe}

%% Where we are going.

\begin{xframe}{What's next?}
  \onslide<2>
  \begin{center}
  \includegraphics[width=4in]{trello}
  \end{center}
\end{xframe}

\begin{xframe}{What's next?}
  \begin{itemize}
  \item<+-> Google Summer of Code project to allow \emph{editing} diagrams.
  \item<+-> Animations and interactivity.
  \item<+-> Bidirectional GUI/code editor.
  \item<+-> Open to suggestions!
  \end{itemize}
\end{xframe}

\begin{xframe}
  \begin{center}
    \begin{diagram}[width=50]
      import Diagrams.Example.Logo

      dia = ico_d
    \end{diagram}
    \vfill
    \url{http://projects.haskell.org/diagrams}
  \end{center}
\end{xframe}

% \begin{xframe}
%   \begin{center}
%   \begin{diagram}[width=150]
%     shapes = hcat' (with & sep .~ 3)
%            [ square 2 # fc green # named "s"
%            , circle 1 # fc blue  # named "c"
%            ]
%     dia = shapes # connectOutside' (with & gap .~ 0.2) "s" "c" # lw 0.03
%         # frame 0.5
%   \end{diagram}
%   \begin{spec}
% shapes = hcat' (with & sep .~ 3)
%        [ square 2  # fc green  # named "s"
%        , circle 1  # fc blue   # named "c"
%        ]
% dia = shapes
%     # connectOutside' (with & gap .~ 0.2)
%       "s" "c"
%   \end{spec}
%   \end{center}
% \end{xframe}

% \begin{xframe}{Flexible}
%   %%% Flexible: multiple vector spaces (2D, 3D); many backends (cairo,
%   %%% SVG, postscript, povray, ...)

%   %%% XXX todo: vertically center images
%   %%% XXX todo: add something about diagrams, with arrows?
%   %%% XXX todo: mention OpenGL, HTML5 canvas, PGF, PDF!

%   \hfill \includegraphics[width=0.5in]{Cairo-logo}
%   \hfill \includegraphics[width=0.8in]{postscript-logo}
%   \hfill \includegraphics[width=0.5in]{Povray-logo}
%   \hfill \includegraphics[width=0.5in]{SVG-logo}
%   \hfill
% \end{xframe}


\end{document}