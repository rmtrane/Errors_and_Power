# Define UI for application that draws a histogram
fluidPage(

  # Application title
  titlePanel("Type I Error related to Type II Error"),

  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(width = 3,
                 sliderInput("alpha",
                             HTML("Type I error rate (&alpha;):"),
                             min = 0.0001,
                             max = 0.9999,
                             value = 0.05,
                             step = 0.001),
                 sliderInput("true_mean",
                             HTML('Difference between hypothesized mean and "true" mean (&mu;<sub>0</sub> - &mu;<sub>A</sub>)'),
                             min = 0,
                             max = 3,
                             value = 0,
                             step = 0.1),
                 sliderInput("true_sd",
                             HTML("True Standard Deviation (&sigma;)"),
                             min = 0.1,
                             max = 3,
                             value = 1,
                             step = 0.1),
                 sliderInput("n",
                             "Sample size (n)",
                             min = 1,
                             max = 100,
                             value = 1,
                             step = 1),
                 conditionalPanel("input.true_mean == 0",
                                  checkboxInput("show_typeI",
                                                "Show Type I Error",
                                                value = FALSE)),
                 conditionalPanel("input.true_mean != 0",
                                  checkboxInput("show_typeII",
                                                "Show Type II Error",
                                                value = FALSE),
                                  checkboxInput("show_power",
                                                "Show Power",
                                                value = FALSE))
    ),

    # Show a plot of the generated distribution
    mainPanel(
      plotOutput("main_plot")
    )
  )
)