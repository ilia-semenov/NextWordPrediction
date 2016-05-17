library(shiny)
library(shinythemes)
library(shinyjs)


# Define UI for application
shinyUI(fixedPage(
        theme = shinytheme("cosmo"),
        titlePanel("Next Word Prediction"),
        tabPanel(
                "Tool",
                sidebarLayout(
                        sidebarPanel(
                                useShinyjs(),
                                div(id = "gen_but", actionButton("gen", "Autogenerator")),
                                div(id = "stop_but", uiOutput("stop")),
                                div(
                                        textInput(
                                                "text",
                                                label = h4("Type something:"),
                                                value = "",
                                                placeholder = "your text here"
                                        ),
                                        onchange = "move()",
                                        onfocusout = "move()",
                                        title = "Press Enter to paste the most likely word"
                                ),
                                div(style = "display:inline-block;margin-bottom: 3px;", uiOutput("w1")),
                                div(style = "display:inline-block;margin-bottom: 3px;", uiOutput("w2")),
                                div(style = "display:inline-block;margin-bottom: 3px;", uiOutput("w3")),
                                div(style = "display:inline-block;margin-bottom: 3px;", uiOutput("w4")),
                                div(style = "display:inline-block;margin-bottom: 3px;", uiOutput("w5")),
                                tags$script(
                                        '$(document).keyup(function(event){
                                        if(event.keyCode == 13){
                                        $("#preds").click();
                                        }
                                        });
                                        function move() {
                                        $("#text").get(0).scrollLeft = $("#text").get(0).scrollWidth;
                                        };
                                        '
                        )
                        ),
                        # Show input speed value as well as predicted stopping distance
                        mainPanel(h3("YOUR AWESOME TEXT"),
                                  h4(htmlOutput(align = "justify", "text_out")),
                                  h4(htmlOutput("word_out")))
                        ),
                div(id = "doc_but", actionButton("docb", "Show documentation")),
                div(id = "cdoc_but", uiOutput("cdocb"))
                        ),
        
        tabPanel(
                id = "doc",
                hidden = TRUE,
                "Documentation",
                fixedPage(
                        theme = shinytheme("cosmo"),
                        titlePanel("Next Word Prediction (NWP) Tool by Ilia Semenov"),
                        
                        navlistPanel(
                                tabPanel(
                                        "Overview",
                                        h3("Overview"),
                                        p(
                                                align = "justify",
                                                "Next Word Prediction (further NWP) tool
                                                is a project created within the ",
                                                tags$a(href =
                                                               "https://www.coursera.org/specializations/jhu-data-science", "John Hopkins University
                                                       Data Science Specialization"),
                                                "course hosted by Coursera. This is
                                                a final task of the specialization (10 courses on various aspects of Data Science)."
                                                ),
                                        p(
                                                align = "justify",
                                                "As the title of the tool might suggest, the project
                                                is focused on NLP area of machine learning. The main idea
                                                is to create the algorithm capable of predicting the next
                                                word based on the preceding input, as well as to implement it
                                                within a user-friendly web-based tool. A good example of
                                                the successful product based on the similar idea is a
                                                Swiftkey app available for mobile devices. This app
                                                predicts the user input with a high level of accuracy and
                                                moreover it learns from user increasing its performance.
                                                Swiftkey were partnering with JHU for this project support,
                                                so that even though the NWP tool you are using now is not
                                                any as complicated as the Swiftkey's one, it utilizes the similar
                                                ideas at its core."
                                        )
                                        ),
                                tabPanel(
                                        "How To Use",
                                        h3("How To Use"),
                                        p(
                                                align = "justify",
                                                "Using the tool is very simple - above you can see the panel with
                                                buttons and a text input fields. Start using the tool by simply
                                                typing in the text input field - your text will be shown to the right
                                                as well as the next word predicted by the algorithm. This is the basic
                                                functionality, but the toll has more to offer."
                                        ),
                                        h4("Word Predictions: Buttons"),
                                        p(
                                                align = "justify",
                                                "The buttons under the text field contain the predicted words completing
                                                you input. The maximum number of options is set to 5, and they are ordered
                                                from left to right based on descending probability, i.e. the top most-left
                                                word is the most likely (it is also shown in output to the right). If less than
                                                5 buttons are displayed, this means that less than 5 options are available."
                                        ),
                                        h4("Press Enter"),
                                        p(
                                                align = "justify",
                                                "Pressing the Enter button on your keyboard automatically appends the most likely
                                                next word to you input."
                                        ),
                                        h4("Some Fun: Autogenerate"),
                                        p(
                                                align = "justify",
                                                "Autogenerate button above the input field is created to demonstrate how algorithm
                                                can produce the text by itself. Just click the button and you will see the text being
                                                generated automatically. Due to the simplicity of algorithm used (dictated by various
                                                constraints), the text will not probably make any sense, but it might be funny at least.
                                                Once you are tired from the crazy output, just press the Stop button that is located
                                                in place of Autogenerate button."
                                        )
                                        ),
                                tabPanel(
                                        "Algorithm and Data",
                                        h3("Algorithm and Data"),
                                        h4("Algorithm"),
                                        p(
                                                align = "justify",
                                                "The algorithm used here to predict the next word based on the preceding input is called
                                                the Stupid Back-Off (SBO). It belongs to the family of the Markov Chain language
                                                generating algorithms that are based on the assumption that the word depends on the limited
                                                number of preceding words."
                                        ),
                                        p(
                                                align = "justify",
                                                "This algorithm takes the language N-Grams (sequences of N words) as input and outputs
                                                the score for each word conditioned on previous words. The higher the score, the more
                                                probable the word in the given context."
                                        ),
                                        p(
                                                align = "justify",
                                                "To learn more about the SBO algorithm, please read the following article: ",
                                                tags$a(
                                                        href = "https://lagunita.stanford.edu/c4x/Engineering/CS-224N/asset/slp4.pdf",
                                                        "Speech and Language Processing. Daniel Jurafsky & James H. Martin."
                                                ),
                                                " Here we will just note that it is the algorithm that was used to
                                                create Google N-Gram database based on millions documents from web. This algorithm is simpler than many other (such as Kneser-Ney or even Turing), but
                                                it provides high run time performance, simplicity of calculations and comparatively good accuracy given the large training data set."
                                        ),
                                        h4("Data"),
                                        p(
                                                align = "justify",
                                                HTML(
                                                        '<p align="justify">The data source for this project is the <a href="http://www.corpora.heliohost.org/aboutcorpus.html">HC Corpora language database</a>. It contains the raw text data for multiple languages obtained by the web crawler. The main sources are:</p>
                                                        <ul>
                                                        <li>News - news sites/aggregators;</li>
                                                        <li>Blogs - blogging resources;</li>
                                                        <li>Twitter.</li>
                                                        </ul>
                                                        <p align="justify">As per scope of this project, only the English part of the corpus is used to train the algorithm. It is 556MB of english text, with 3M lines and <b>70M words</b>. More information on the data as well as some EDA can be found here: <a href="http://rpubs.com/isemenov/jhu_ds_capstone">HC Corpora EDA by Ilia Semenov</a>.</p>
                                                        <p align="justify">For training the algorithm 4-Gram model was chosen (i.e. all sequences up to 4 words were generated) and most infrequent sequences were deleted (4-Grams with counts 1). This was done due to the physical memory limitations enforced by ShinyApps, however, as the research has shown, the accuracy did not decline much due to limitations. Overall accuracy of the algorithm based on this data is about <b>12%</b>.</p>
                                                        '
                                                )
                                                )
                                                ),
                                tabPanel("Author",
                                         h3("Author"),
                                         p(
                                                 tags$a(href = "http://iliasemenov.com", "Ilia Semenov"), ", 2016"
                                         ))
                                                )
                                        )
                                        )
                                        ))


