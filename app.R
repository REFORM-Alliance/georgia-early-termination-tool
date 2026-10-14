rm(list = ls())


####Read in Libraries####
library(shiny)
library(tidyverse)
library(shinythemes)
library(rsconnect)
library(shinyWidgets)
library(lubridate)
library(scales)
library(shinyjs)
library(shinyalert)
library(shiny.i18n)
library(googleLanguageR)
library(here)


####Initialize Translator for Automatic Translation####
i18n <- Translator$new(translation_json_path = here("json", "translation.json"))

##Set default language
i18n$set_translation_language("en")


####Write Decision Tree####
decision_tree <- 
  list(
    list(
      intro = TRUE, 
      content_above_buttons =
        tags$div(
          tags$p(strong("Welcome to REFORM Alliance's Georiga Early Termination Tool.")),
          tags$p("This tool is designed to help users navigate the process for early termination of probation in Georgia. It only applies to people on probation, not parole."),
          tags$p("This tool can be used by anyone, but is specifically designed to be used by people on probation. To begin using the tool, please click the START button below.")
        ), 
      next_question = "initial_question",
      question_id = "intro_page"
    ),
    list(
      question = 
        tags$div(
          tags$p("First we need to ask if you are on probation for a felony or misdemeanor. We ask this question first because Georgia law provides very different options for felony and misdemeanor cases."),
          tags$p("Were you sentenced to probation for a felony or misdemeanor?")
        ),
      choices = c("Felony", "Misdemeanor"),
      question_id = "initial_question",
      next_question = list(
        "Felony" = "felony_q1",
        "Misdemeanor" = "misdemeanor_result"
      )
    ),
    list(
      result = 
        tags$div(
          tags$p("You can ask a judge to terminate your probation early! There is no automatic process to make this happen, so you will need to file a motion with a court. This is permitted at any time under ",
                 tags$a(href='https://law.justia.com/codes/georgia/title-42/chapter-8/article-2/section-42-8-37/', target='_blank', class='external-link', "Georgia Code 42-8-37"),
                 "; if you are on pay-only probation, it is permitted under ", 
                 tags$a(href='https://codes.findlaw.com/ga/title-42-penal-institutions/ga-code-sect-42-8-103/', target='_blank', class='external-link', "Georgia Code 42-8-103"),
                 ". Please consult with a lawyer with any questions about this process.")
        ),
      question_id = "misdemeanor_result"
    ), 
    list(
      question = 
        tags$div(
          tags$p(strong("Next we need to ask you about your criminal history and the nature of your sentence. This is important because it helps determine when you might be eligible for early termination."))
        ),
      question_list = 
        list("q1" = tags$p("Were you sentenced to a lifetime probation for a sexual felony as defined in ",
                           tags$a(href='https://codes.findlaw.com/ga/title-16-crimes-and-offenses/ga-code-sect-16-5-21/', target='_blank', class='external-link', "Georgia Code section 16-5-21"),
                           "?"),
             "q2" = tags$p("Did you have any felony convictions BEFORE the case that put you on probation?"), 
             "q3" = tags$p("Were you sentenced to more than one year of incarceration in addition to your probation sentence? For this question, only a sentence of incarceration of more than 1 year counts, not time served in jail before your sentence.")),
      choices = c("Yes", "No"),
      question_id = "felony_q1",
      next_question = list(
        "Yes1" = "felony_q1_yes1_result",
        "Yes2" = "qualified_offense_question",
        "No" = "felony_q1_no_result"
      )
    ),
    list(
      question = 
        tags$div(
          tags$p("You are eligible for early termination after serving 10 years on probation. Click below to see what happens next")
        ),
      question_id = "felony_q1_yes1_result",
      next_question = "felony_q1_yes1_questions"
    ),
    list(
      question = 
        tags$div(
          tags$p(strong("Next we need to ask you some questions about your time on probation. The answers to these questions will determine what you may be eligible for."))
        ),
      question_list =
        list("q1" = tags$p("Were you arrested at any time while on probation for anything other than a non-serious traffic offense? A non-serious traffic offense is defined ",
                           tags$a(href='https://codes.findlaw.com/ga/title-35-law-enforcement-officers-and-agencies/ga-code-sect-35-3-37/', target='_blank', class='external-link', "here")),
             "q2" = tags$p("Do you owe any restitution?"),
             "q3" = tags$p("Have you had your probation revoked? This does not mean that you had a violation filed, it means your probation was actually revoked."),
             "q4" = tags$p("Have you been classified as a sexually dangerous predator by the Sexual Offender Risk Review Board? If you do not know the answer to this question, please discuss it with your probation officer.")),
      choices = c("Yes", "No"),
      question_id = "felony_q1_yes1_questions",
      next_question = list(
        "Yes" = "no_automatic_process_result", 
        "No" = "required_early_term_file_message"
      )
    ),
    list(
      question = 
        tags$div(
          tags$p("On the date that you are eligible, the Department of Community Supervision is required to file paperwork with the court applying for your early termination. Essentially, they are required to file for your early termination for you!"),
          tags$p("You should be aware that as part of this process, the Georgia Department of Community Safety is required to request an updated classification from the Sexual Offender Risk Review Board at least 6 months prior to filing the paperwork with the court. The Sexual Offender Risk Reiew Board is required to provide an updated classification."),
          tags$p("Click below to see what happens next")
        ),
      question_id = "required_early_term_file_message",
      next_question = "required_early_term_file_result"
    ), 
    list(
      result = 
        tags$div(
          tags$p("This is not the end of the process. At this point, a judge has discretion to grant or deny the petition for early termination. The judge is legally requird to take “whatever action it determines would be for the best interest of justice and the welfare of society.” The judge must also notify your prosecutor’s office and the state’s Board of Pardons and Paroles, and give your prosecutor’s office the opportunity to be heard on the issue of early termination."),
          tags$p("If your petition is granted, your period of supervision is finished! If it is denied, your probation officer must file another petition every 5 years."),
          tags$p("Please consult with a lawyer for any questions you have about this process.")
        ),
      question_id = "required_early_term_file_result"
    ),
    list(
      result = 
        tags$div(
          tags$p("You can still ask a judge to terminate your probation early, but there is no automatic process to make this happen, you will need to file a motion with a court. This is permitted at any time under ",
                 tags$a(href='https://law.justia.com/codes/georgia/title-42/chapter-8/article-2/section-42-8-37/', target='_blank', class='external-link', "Georgia Code 42-8-37"), 
                 ". Please consult with a lawyer with any questions about this process.")
        ),
      question_id = "no_automatic_process_result"
    ), 
    list(
      question = 
        tags$div(
          tags$p("A judge was required to set a “Behavioral Incentive Date” at the time of your sentencing, though not all judges actually do this. If a Behavioral Incentive Date was set by your judge, then you are eligible for early termination within 60 days of this date."),
          tags$p("If a judge did not set a Behavioral Incentive Date, then you are eligible for early termination after serving 3 years on probation."),
          tags$p("Click below to see what happens next.")
        ),
      question_id = "felony_q1_no_result",
      next_question = "time_on_probation_questions"
    ),
    list(
      question = 
        tags$div(
          tags$p(strong("Next we need to ask you some questions about your time on probation. The answers to these questions will determine what you may be eligible for.")),
        ),
      question_list = 
        list("q1" = tags$p("Were you arrested at any time while on probation for anything other than a non-serious traffic offense? A non-serious traffic offense is defined ",
                           tags$a(href='https://codes.findlaw.com/ga/title-35-law-enforcement-officers-and-agencies/ga-code-sect-35-3-37/', target='_blank', class='external-link', "here"), "."),
             "q2" = tags$p("Do you owe any restitution?"), 
             "q3" = tags$p("Have you had your probation revoked in the past 2 years? This does not mean that you had a violation filed, it means your probation was actually revoked.")),
      choices = c("Yes", "No"), 
      question_id = "time_on_probation_questions", 
      next_question = 
        list(
          "Yes" = "no_automatic_process_result", 
          "No" = "required_early_term_file_result_2"
        )
    ),
    list(
      result = 
        tags$div(
          tags$p("On the date that you are eligible, the Department of Community Supervision is required to file paperwork with the court applying for your early termination. Essentially, they are required to file for your early termination for you!"),
          tags$p("This is not the end of the process, however. At this point, either the prosecutor or the judge may object to your early termination, within 30 days of receiving the paperwork. If this occurs, the judge must hold a hearing to decide whether to grant you early termination within 90 days. They are required to “take whatever action it determines would be for the best interest of justice and the welfare of society.” It may be helpful to discuss how to best present your case to the judge with your probation officer or your attorney."),
          tags$p("Please consult with a lawyer for any questions you have about this process.")
        ),
      question_id = "required_early_term_file_result_2"
    ),
    list(
      question = 
        tags$div(
          tags$p("Next we need to ask you about your crime of conviction."),
          tags$p("Were you convicted of a “qualified offense?” A “qualified offense” is defined ", 
                 tags$a(href='https://law.justia.com/codes/georgia/title-42/chapter-8/article-2/section-42-8-21/', target='_blank', class='external-link', "here"), ".")
        ),
      choices = c("Yes", "No"), 
      question_id = "qualified_offense_question",
      next_question = 
        list(
          "Yes" = "automatic_3_year_eligibility_message", 
          "No" = "automatic_3_year_eligibility_po_question"
        )
    ),
    list(
      question = 
        tags$div(
          tags$p("You are eligible for early termination after serving 3 years on probation."),
          tags$p("You can apply at any time before or after then for early termination, but you will automatically be eligible after 3 years. Click below to see what happens next.")
        ),
      question_id = "automatic_3_year_eligibility_message",
      next_question = "time_on_probation_questions"
    ),
    list(
      question = 
        tags$div(
          tags$p("You are eligible for early termination after serving 3 years on probation."),
          tags$p("When you become eligible, your probation officer has the option to file paperwork with the court applying for your early termination. It is important to talk to your probation officer about whether to file this or not."),
          tags$p("Did your probation officer file for early termination on your behalf?")
        ),
      choices = c("Yes", "No"),
      question_id = "automatic_3_year_eligibility_po_question",
      next_question = 
        list(
          "Yes" = "early_term_possible_hearing_result", 
          "No" = "no_automatic_process_result"
        )
    ),
    list(
      result = 
        tags$div(
          tags$p("This is not the end of the process. At this point, either the prosecutor or the judge may object to your early termination, within 30 days of receiving the paperwork. If this occurs, the judge must hold a hearing to decide whether to grant you early termination within 90 days. They are required to “take whatever action it determines would be for the best interest of justice and the welfare of society.” It may be helpful to discuss how to best present your case to the judge with your probation officer or your attorney."),
          tags$p("Please consult with a lawyer for any questions you have about this process.")
        ),
      question_id = "early_term_possible_hearing_result"
    )
  )


####Create App####
ui <- fluidPage(
  usei18n(i18n),
  # title = uiOutput("app_title"),
  title = "Georgia Early Termination Tool",
  useShinyjs(),
  theme = shinytheme("flatly"),
  tags$head(
    tags$style(HTML(
      "
      .question-text{ font-size: 20px; margin-bottom: 30px; margin-top: 30px}
      .result-text{ font-size: 20px; font-weight: bold; color: #28a745; margin-top: 20px; }
      .shiny-input-container{ margin-bottom: 10px; }
      .btn-container{ margin-top: 20px; }
      .logo-container{ text-align: center; margin-bottom: 40px; margin-top: 10px;}
      .logo{ max-width: 200px; height: auto; }
      
      .language-picker-container {
        min-height: 90px;
        display: flex;
        flex-direction: column;
        justify-content: flex-start;
      }
      .language-picker-container .bootstrap-select .dropdown-toggle {
        white-space: nowrap;
        min-height: 34px;
      }
      /* Custom button styling */
      #violation-buttons .btn{
        margin-right: 10px;
        margin-bottom: 10px; /* Add bottom margin for spacing */
        border: 1px solid #ccc;
        padding: 10px 15px;
        font-size: 16px;
        min-width: 200px; /* Adjust as needed */
        text-align: center;
      }
      #violation-buttons .btn.active{
        border-color: #007bff;
        box-shadow: 0 0 5px rgba(0, 123, 255, 0.5);
      }
      #violation-buttons .btn-danger{
        background-color: #dc3545;
        color: white;
      }
      #violation-buttons .btn-success{
        background-color: #28a745;
        color: white;
        min-width: 250px;
        height: 60px;
        padding: 0 20px;     /* Horizontal padding only */
        font-size: 18px;
        line-height: 60px;
        text-align: center;
      }

      #start_button{
        font-size: 24px; /* Increase font size */
        padding: 15px 30px; /* Increase padding */
        min-width: 280px; /* Adjust width as needed */
        height: 70px;    /* Adjust height as needed */
        display: flex;        /* Enable flexbox */
        justify-content: center; /* Center horizontally */
        align-items: center;    /* Center vertically */
      }
      "
    )),
    
    tags$script(HTML("
    $(document).on('click', 'a.external-link', function(e){
      e.preventDefault();
      var $this = $(this);
      var href = $this.attr('href');
      $this.data('href-backup', href); // Backup the href
      Shiny.setInputValue('js_href', href);
    });
    Shiny.addCustomMessageHandler('open_url', function(message){
      window.open(message, '_blank');
      // No need to restore here, navigation happens
    });
    Shiny.addCustomMessageHandler('remove_href', function(href){
      $('a.external-link[data-href-backup=\"' + href + '\"]').each(function(){
        $(this).removeAttr('href'); // Temporarily remove href
      });
    });
    Shiny.addCustomMessageHandler('restore_href', function(href){
      $('a.external-link[data-href-backup=\"' + href + '\"]').each(function(){
        $(this).attr('href', $(this).data('href-backup'));
        $(this).removeData('href-backup');
      });
    });
    ")),
    
    tags$script(HTML("
    Shiny.addCustomMessageHandler('update-title', function(message){
      document.title = message;
    });
    "))
  ),
  
  div(class = "logo-container",
      img(src = "reform-logo-charcoal.png", class = "logo")
  ),
  
  div(strong(uiOutput("main_app_title")),
      style = "font-size: 40px; margin-top: 60px; margin-bottom: 40px; text-align: center;"
  ),
  
  div(
    class = "language-picker-container",
    pickerInput(
      inputId = "selected_language",
      label = "Change Language",
      choices = c("en", "es"),
      selected = i18n$get_translation_language(),
      choicesOpt = list(
        content = c(
          paste0("<i class='flag-icon flag-icon-us'></i> ", i18n$t("English")),
          paste0("<i class='flag-icon flag-icon-es'></i> ", i18n$t("Español"))
        )
      ),
      options = list(
        style = "btn-primary", 
        `live-search` = FALSE, 
        `selected-text-format` = "count > 2", 
        width = "180px"
      )
    )
  ),
  
  uiOutput("quiz_ui"),
  div(class = "btn-container",
      uiOutput("button_ui")
  )
)


####Server####
server <- function(input, output, session){
  i18n_r <- reactive({
    selected <- input$selected_language
    if(length(selected) > 0 && selected %in% i18n$get_languages()){
      i18n$set_translation_language(selected)
    }
    i18n
  })

  get_english_key <- function(translated_answer_from_input, current_lang_code){
    if(is.null(translated_answer_from_input) ||
       length(translated_answer_from_input) == 0 ||
       nchar(translated_answer_from_input) == 0){
      return(NULL)
    }
    
    if(current_lang_code == "en"){
      return(translated_answer_from_input)
    }else if(current_lang_code == "es"){
      translation <- 
        as.data.frame(i18n_r()$get_translations()) %>% 
        rownames_to_column("en") %>% 
        filter(es == translated_answer_from_input) %>% 
        pull(en)
      if(length(translation) == 0) return(NULL)
      return(translation[1])
    }
  }
  
  output$app_title <- renderText({
    i18n_r()$t("Georgia Early Termination Tool")
  })
  
  output$main_app_title <- renderText({
    i18n_r()$t("Georgia Early Termination Tool")
  })
  
  history <- reactiveVal(c(1))
  selected_answer <- reactiveVal(NULL)
  answer_selected <- reactiveVal(FALSE)
  stored_answers <- reactiveValues()
  
  observeEvent(input$js_href, {
    href <- input$js_href
    
    shinyalert(
      title = i18n_r()$t("Leaving Application"),
      text = i18n_r()$t("This will take you to a new website."),
      type = "info",
      showCancelButton = TRUE,
      confirmButtonText = i18n_r()$t("Continue"),
      callbackR = function(x){
        if(isTRUE(x)){
          session$sendCustomMessage("open_url", href)
          session$sendCustomMessage("remove_href", href)
        }else{
          session$sendCustomMessage("restore_href", href)
        }
      }
    )
  }, ignoreInit = TRUE)
  
  translate_ui_recursive <- function(element, translator_reactive){
    
    if(is.character(element)){
      return(translator_reactive()$t(element))
    }
    
    if(inherits(element, "shiny.tag") || inherits(element, "htmltools.tag")){
      
      if(!is.null(element$children)){
        element$children <- lapply(
          element$children,
          function(child){
            translate_ui_recursive(child, translator_reactive)
          }
        )
      }
      
      return(element)
    }
    
    if(is.list(element)){
      return(
        lapply(
          element,
          function(child){
            translate_ui_recursive(child, translator_reactive)
          }
        )
      )
    }
    
    return(element)
  }
  
  ##Quiz UI
  output$quiz_ui <- renderUI({
    current_index <- tail(history(), 1)
    current_question <- decision_tree[[current_index]]
    
    if(length(current_question$intro) > 0){
      tagList(
        translate_ui_recursive(current_question$content_above_buttons, i18n_r),
        uiOutput("intro_buttons"),
        translate_ui_recursive(current_question$content_below_buttons, i18n_r)
      )
    }else if("question" %in% names(current_question) &&
             length(current_question$question_list) == 0){
      tagList(
        translate_ui_recursive(current_question$question, i18n_r),
        if("choices" %in% names(current_question) &&
           length(current_question$choices) > 0){
          stored <- isolate(stored_answers[[current_question$question_id]])
          radioButtons("answer", NULL,
                       selected = if(!is.null(stored)) i18n_r()$t(stored) else character(0),
                       choices = lapply(current_question$choices, function(x) i18n_r()$t(x)))
        }
      )
    }else if("question" %in% names(current_question) &&
             length(current_question$question_list) > 0){
      tagList(
        translate_ui_recursive(current_question$question, i18n_r),
        current_question %>%
          pluck("question_list") %>%
          enframe() %>%
          pmap(
            ~tagList(
              div(tags$div(tags$p(translate_ui_recursive(.y, i18n_r)))), 
              radioButtons(
                inputId = paste0("answer_", .x),
                selected = {
                  stored <- isolate(stored_answers[[paste0(current_question$question_id, "___answer_", .x)]])
                  if(!is.null(stored)) i18n_r()$t(stored) else character(0)
                },
                label = NULL,
                choices = lapply(c("Yes", "No"), function(x) i18n_r()$t(x)) 
              )
            )
          ),
        if(!is.null(current_question$note_text)){
          translate_ui_recursive(current_question$note_text, i18n_r)
        }
      )
    }else if("result" %in% names(current_question)){
      translate_ui_recursive(current_question$result, i18n_r)
    }
  })
  
  output$intro_buttons <- renderUI({
    div(
      actionButton("start_button", i18n_r()$t("Start"), class = "btn btn-success")
    )
  })
  
  output$button_ui <- renderUI({
    current_index <- tail(history(), 1)
    current_question <- decision_tree[[current_index]]
    buttons <- list()
    
    if(current_question$question_id == "resource_question"){
      buttons <- list(actionButton("back_button", i18n_r()$t("Go Back to Previous Question"), class = "btn btn-warning"))
    }else{
      if(length(history()) > 1 & current_question$question_id != "intro_page"){
        buttons <- append(buttons, list(actionButton("back_button", i18n_r()$t("Back"), class = "btn btn-warning")))
      }
      
      if(current_question$question_id == "finished_page"){
        buttons <- append(buttons, list(actionButton("start_over_button", i18n_r()$t("Start Over"), class = "btn btn-success")))
      }else if(is.null(current_question$next_question)){
        buttons <- append(buttons, list(actionButton("finish_button", i18n_r()$t("Finish"), class = "btn btn-danger")))
      }else if(length(current_question$intro) == 0){
        buttons <- append(buttons, list(actionButton("next_button", i18n_r()$t("Next"), class = "btn btn-primary")))
      }
    }
    
    do.call(fluidRow, buttons)
  })
  
  observeEvent(input$answer, {
    current_index <- tail(history(), 1)
    current_question <- decision_tree[[current_index]]
    
    # list-style questions are handled by the observe() in FIX 4
    req(length(current_question$question_list) == 0,
        "choices" %in% names(current_question))
    
    english_key <- get_english_key(input$answer, input$selected_language)
    
    # only accept answers that are actually a route out of this question
    if(!is.null(english_key) && english_key %in% names(current_question$next_question)){
      answer_selected(TRUE)
      selected_answer(english_key)
      stored_answers[[current_question$question_id]] <- english_key
    }else{
      answer_selected(FALSE)
      selected_answer(NULL)
    }
  })
  observe({
    answer_selected_val = answer_selected()
    if(!is.null(answer_selected_val) & answer_selected_val == TRUE){
      shinyjs::enable("next_button")
    }else{
      shinyjs::disable("next_button")
    }
  })
  
  observe({
    current_index <- tail(history(), 1)
    current_question <- decision_tree[[current_index]]
    
    req(length(current_question$question_list) > 0)
    
    current_lang_code <- input$selected_language
    answer_ids <- paste0("answer_", names(current_question$question_list))
    
    # "Yes"/"No" in English, or NULL if unanswered / not a recognised answer
    get_yes_no <- function(id){
      val <- get_english_key(input[[id]], current_lang_code)
      if(length(val) == 1 && val %in% c("Yes", "No")) val else NULL
    }
    
    responses <- lapply(answer_ids, get_yes_no)
    names(responses) <- answer_ids
    
    # remember what has been answered so far (restored if the person goes Back)
    for(id in answer_ids){
      if(!is.null(responses[[id]])){
        stored_answers[[paste0(current_question$question_id, "___", id)]] <- responses[[id]]
      }
    }
    
    if(any(vapply(responses, is.null, logical(1)))){
      # not every sub-question answered yet
      answer_selected(FALSE)
      selected_answer(NULL)
    }else{
      responses <- unlist(responses)
      answer_selected(TRUE)
      
      if(current_question$question_id == "felony_q1"){
        if(responses[["answer_q1"]] == "Yes"){
          selected_answer("Yes1")
        }else if(responses[["answer_q2"]] == "Yes" || responses[["answer_q3"]] == "Yes"){
          selected_answer("Yes2")
        }else{
          selected_answer("No")
        }
      }else{
        selected_answer(if("Yes" %in% responses) "Yes" else "No")
      }
    }
  })
  
  observeEvent(input$go_to_resource, {
    resource_index <- which(map_chr(decision_tree, "question_id") == "resource_question")
    history(c(history(), resource_index))
  })
  
  observeEvent(input$start_button, {
    current_question <- decision_tree[[1]]
    next_id <- current_question$next_question
    next_index <- which(map_chr(decision_tree, "question_id") == next_id)
    history(c(history(), next_index))
  })
  
  observeEvent(input$next_button, {
    current_index <- tail(history(), 1)
    current_question <- decision_tree[[current_index]]
    answer_selected_val <- answer_selected()
    if(answer_selected_val == FALSE && !("result" %in% names(current_question)) && !(length(current_question$next_question) == 1 && !("choices" %in% names(current_question)))){
      shinyalert(
        title = i18n_r()$t("Missing answer"),
        text = i18n_r()$t("Please select an answer before clicking Next"),
        type = "warning"
      )
      return()
    }
    
    if("choices" %in% names(current_question)){
      req(selected_answer())
      next_id <- current_question$next_question[[selected_answer()]]
    }else{
      next_id <- current_question$next_question
    }
    
    req(next_id)
    
    next_index <- which(map_chr(decision_tree, "question_id") == next_id)
    history(c(history(), next_index))
    answer_selected(FALSE) 
    selected_answer(NULL) 
  })
  
  observeEvent(input$back_button, {
    answer_selected(FALSE)
    selected_answer(NULL)
    if(length(history()) > 1){
      history(history()[1:(length(history()) - 1)])
      answer_selected(FALSE)
      selected_answer(NULL)
    }
  })
  
  observeEvent(input$start_over_button, {
    history(c(1))
    answer_selected(FALSE)
    selected_answer(NULL)
    for(nm in names(reactiveValuesToList(stored_answers))){
      stored_answers[[nm]] <- NULL
    }
  })
  
  observeEvent(input$finish_button, {
    finished_page_index <- which(map_chr(decision_tree, "question_id") == "finished_page")
    history(c(history(), finished_page_index))
  })
  
  observeEvent(input$selected_language, {
    current_i18n <- i18n_r()
    
    updatePickerInput(
      session,
      inputId = "selected_language",
      label = current_i18n$t("Change Language"),
      choices = c("en", "es"),
      selected = input$selected_language,
      choicesOpt = list(
        content = c(
          paste0("<i class='flag-icon flag-icon-us'></i> ", current_i18n$t("English")),
          paste0("<i class='flag-icon flag-icon-es'></i> ", current_i18n$t("Español"))
        )
      )
    )
  }, ignoreInit = FALSE)
}

##Deploy App
shinyApp(ui = ui, server = server)



