# Define UI for application that draws a histogram
fluidPage(
  # Get rid of numbers from slider
  tags$head(tags$style(HTML('.irs-from, .irs-to, .irs-min, .irs-max {
            visibility: hidden !important;
    }'))),
  # Application title
  titlePanel("Type I Error related to Type II Error"),

  # Sidebar with a slider input for number of bins
  wellPanel(
    fluidRow(
      column(
        6,
        sliderInput("alpha",
                    HTML("Type I error rate (&alpha;):"),
                    min = 0.0001,
                    max = 0.5,
                    value = 0.05,
                    step = 0.001)
      ),
      column(
        6,
        sliderInput("n",
                    "Sample size (n)",
                    min = 1,
                    max = 100,
                    value = 1,
                    step = 1)
      )
    ),
    fluidRow(
      column(
        6,
        sliderInput("true_mean",
                    HTML('Difference between hypothesis and truth (&mu;<sub>0</sub> - &mu;<sub>A</sub>)'),
                    min = 0,
                    max = 10,
                    value = 0,
                    step = 0.1)
      ),
      column(
        6,
        sliderInput("true_sd",
                    HTML("True Standard Deviation (&sigma;)"),
                    min = 0.1,
                    max = 5,
                    value = 1,
                    step = 0.1)
      )
    ),
    fluidRow(
      conditionalPanel("input.true_mean == 0",
                       checkboxInput("show_typeI",
                                     "Show Type I Error",
                                     value = FALSE)),
      conditionalPanel("input.true_mean != 0",
                       column(
                         6,
                         checkboxInput("show_typeII",
                                       "Show Type II Error",
                                       value = FALSE)
                       ),
                       column(
                         6,
                         checkboxInput("show_power",
                                       "Show Power",
                                       value = FALSE)
                       )
      )
    )
  ),
  plotOutput("main_plot"),
  wellPanel(
    checkboxInput(inputId = "advanced",
                  label = "Advanced Options"),
    conditionalPanel("input.advanced",
                     uiOutput("x_limits"))
  )
)