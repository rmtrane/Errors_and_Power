#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyverse)

theme_set(theme_bw())

library(viridis)
scale_color_continuous <- scale_colour_continuous <- function(...) scale_color_viridis_c(...)
scale_color_discrete <- scale_colour_discrete <- function(...) scale_color_viridis_d(...)

scale_fill_continuous <- function(...) scale_fill_viridis_c(...)
scale_fill_discrete <- function(...) scale_fill_viridis_d(...)

all_colors <- viridis(n = 5)

fill_colors <- setNames(all_colors[2:4], c('Type I', 'Type II', 'Power'))
line_colors <- setNames(all_colors[c(1,5)], c('Hypothesized', 'True'))

# Define server logic required to draw a histogram
server <- function(input, output) {

    output$main_plot <- renderPlot({

        x_crit <- qnorm(p = 1-input$alpha/2, sd = input$true_sd/sqrt(input$n))

        dat_tibble <- tibble(x = seq(-input$true_sd*3, input$true_mean + input$true_sd*3, by = 0.01)) %>%
            mutate(y_hypo = dnorm(x, sd = input$true_sd/sqrt(input$n)),
                   y_true = dnorm(x, mean = input$true_mean, sd = input$true_sd/sqrt(input$n)))
        # draw the histogram with the specified number of bins
        out_plot <- ggplot(data = dat_tibble,
               aes(x = x)) +
            geom_line(aes(y = y_hypo, color = 'Hypothesized')) +
            geom_line(aes(y = y_true, color = 'True')) +
            geom_vline(data = NULL,
                       linetype = 'dashed',
                       aes(xintercept = 0,
                           color = 'Hypothesized')) +
            geom_vline(data = NULL,
                       aes(xintercept = input$true_mean,
                           color = 'True'),
                       linetype = 'dashed') +
            geom_vline(xintercept = c(-1,1)*x_crit,
                       color = 'red', linetype = 'dashed') +
            scale_y_continuous(expand = expand_scale(mult = c(0,0.1))) +
            scale_fill_manual(values = fill_colors) +
            labs(y = '', x = '', fill = '', color = '')

        if(input$show_typeII){
            out_plot <- out_plot +
                geom_area(data = dat_tibble %>%
                              filter(x <= abs(x_crit),
                                     x >= -abs(x_crit)),
                          aes(x = x, y = y_true, fill = "Type II"),
                          alpha = 0.5)
        }

        if(input$show_typeI){
            out_plot <- out_plot +
                geom_area(data = dat_tibble %>%
                              filter(x <= -abs(x_crit)),
                          aes(y = y_hypo, fill = "Type I"),
                          alpha = 0.5) +
                geom_area(data = dat_tibble %>%
                              filter(x >= abs(x_crit)),
                          aes(y = y_hypo, fill = "Type I"),
                          alpha = 0.5)
        }

        if(input$show_power){
            out_plot <- out_plot +
                geom_area(data = dat_tibble %>%
                              filter(x <= -abs(x_crit)),
                          aes(y = y_true, fill = "Power"),
                          alpha = 0.5) +
                geom_area(data = dat_tibble %>%
                              filter(x >= abs(x_crit)),
                          aes(y = y_true, fill = "Power"),
                          alpha = 0.5)
        }

        return(out_plot)
    })
}

# Run the application
shinyApp(ui = ui, server = server)
