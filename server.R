library(shiny)
library(tidyverse)
library(grid)

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

  output$x_limits <- renderUI({
    sliderInput(inputId = "x_limits",
                label = "Override Default x-axis limits",
                min = -20,
                max = input$true_mean + 20,
                ticks = FALSE,
                #ticks = c(0, input$true_mean),
                value = c(-10, 10))
  })

  output$main_plot <- renderPlot({

    x_crit <- qnorm(p = 1-input$alpha/2, sd = input$true_sd/sqrt(input$n))

#     if(input$true_mean < 0.2){
#       x_breaks <- 0
#       x_labels <- expression(mu[0])
#     } else {
#       x_breaks <- c(0, input$true_mean)
#       x_labels <- c(expression(mu[0]),
#                     expression(mu[A]))
#     }

    x_min <- input$x_limits[1] # ifelse(input$advanced, input$x_limits[1], -10)
    x_max <- input$x_limits[2]# ifelse(input$advanced, input$x_limits[2], 10)

    dat_tibble <- tibble(x = seq(x_min, input$true_mean + x_max, by = 0.01)) %>%
      mutate(y_hypo = dnorm(x, sd = input$true_sd/sqrt(input$n)),
             y_true = dnorm(x, mean = input$true_mean, sd = input$true_sd/sqrt(input$n)))
    # draw the histogram with the specified number of bins
    out_plot <- ggplot(data = dat_tibble,
                       aes(x = x)) +
      geom_line(aes(y = y_true, color = 'T')) +
      geom_line(aes(y = y_hypo, color = 'H')) +
      geom_vline(data = NULL,
                 aes(xintercept = input$true_mean,
                     color = 'T'),
                 linetype = 'dashed') +
      geom_vline(data = NULL,
                 linetype = 'dashed',
                 aes(xintercept = 0,
                     color = 'H')) +
      geom_vline(xintercept = c(-1,1)*x_crit,
                 color = 'blue', linetype = 'dashed',
                 size = 1) +
      scale_x_continuous(breaks = c(0, input$true_mean),
                         labels = c(expression(mu[0]),
                                    expression(mu[A])),
                         guide = guide_axis(check.overlap = TRUE)) +
      scale_y_continuous(limits = c(0, NA),
                         expand = expansion(add = c(0,0), mult = c(0,0.1))) +
      scale_fill_manual(values = fill_colors) +
      scale_color_manual(values = c("black", "red"),
                         labels = c(expression(mu[0], mu[A]))) +
      labs(y = '', x = '', fill = '', color = '') +
      theme(text = element_text(size = 24))

    if(input$show_typeII){

      typeII <- pnorm(abs(x_crit), mean = input$true_mean, sd = input$true_sd/sqrt(input$n)) -
        pnorm(-abs(x_crit), mean = input$true_mean, sd = input$true_sd/sqrt(input$n))
      label <- grobTree(textGrob(paste("Type II:", typeII), x = 0.975, y = 0.95,
                                 hjust = 1, gp = gpar(fontsize = 18, fontface = 'bold', col = 'red')))

      out_plot <- out_plot +
        geom_area(data = dat_tibble %>%
                    filter(x <= abs(x_crit),
                           x >= -abs(x_crit)),
                  aes(x = x, y = y_true, fill = "Type II"),
                  alpha = 0.5) +
        annotation_custom(label)
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

      power <- pnorm(abs(x_crit), mean = input$true_mean, sd = input$true_sd/sqrt(input$n), lower.tail = F) +
        pnorm(-abs(x_crit), mean = input$true_mean, sd = input$true_sd/sqrt(input$n))
      label <- grobTree(textGrob(paste("Power:", power), x = 0.975, y = 0.9,
                                 hjust = 1, gp = gpar(fontsize = 18, fontface = 'bold', col = 'red')))

      out_plot <- out_plot +
        geom_area(data = dat_tibble %>%
                    filter(x <= -abs(x_crit)),
                  aes(y = y_true, fill = "Power"),
                  alpha = 0.5) +
        geom_area(data = dat_tibble %>%
                    filter(x >= abs(x_crit)),
                  aes(y = y_true, fill = "Power"),
                  alpha = 0.5) +
        annotation_custom(label)

    }

    return(out_plot)
  })
}
