# Test code Github #
###################

#### Encrypt and Decryp messages English only####

Encrypt_Decrypt <- function(Message, Encr_decr){
  
  # Define the encryption rule
    abc123 <- as.data.frame(append(strsplit(c('ABCDEFGHIJKLMNOPQRSTUVWXYZ#@&-_()[]{}^$*;,.?:/+!- `%0123456789'), split = '')[[1]], '"'))
  
    
    value <- round(seq(nrow(abc123)) / sum(seq(nrow(abc123))), 4)
    for(i in 1:length(value)){
      value[i] <- value[i] + i
    }
    ref <- data.frame(abc123, as.character(value))
    colnames(ref) <- c('Characters', 'Value')
    
    # Standardize the Values
    for(v in 1:9){
      if(nchar(ref$Value[v]) == 5){
        ref$Value[v] = paste(c(ref$Value[v], '0'), collapse = '')
      }
    }
    for(v in 10:nrow(ref)){
      if(nchar(ref$Value[v]) == 6){
        ref$Value[v] = paste(c(ref$Value[v], '0'), collapse = '')
      }
    }
    
  # Encrypt the message
  tryCatch(
    expr = {
      Output <- c()
      if(Encr_decr == 0){
        no_lett <- c()
        split_msg = toupper(strsplit(Message, split = '')[[1]])
        for(i in 1:length(split_msg)){
          if(is.na(which(ref$Characters == split_msg[i])[1])){
            no_lett <- c(no_lett, split_msg[i], " ")
            Output <- paste(c('The character(s): ', no_lett, 
                            "does not exist, please try again "))
          }else{
            pos_letter = which(ref$Characters == split_msg[i])
            Output <- c(Output, ref$Value[pos_letter])
          }
        }
        Output = paste(Output, collapse = '')
      }else if(Encr_decr == 1){ #Decrypt the Message
        Output <- c()
        # Identify the letters
        pos_dots = unlist(gregexpr("\\.", Message))
        
        # For the first one
        Output <- c(Output, substr(Message, 1, pos_dots[1] + 4))
        # For the rest
        for(p in 2:length(pos_dots)){
          # Test if the value exist in the ref table
          if((substr(Message, pos_dots[p] - 1, pos_dots[p] + 4) %in% ref$Value) == TRUE){
            Output <- c(Output, substr(Message, pos_dots[p] - 1, pos_dots[p] + 4))
          }else if((substr(Message, pos_dots[p] - 2, pos_dots[p] + 4) %in% ref$Value) == TRUE){
            Output <- c(Output, substr(Message, pos_dots[p] - 2, pos_dots[p] + 4))
          }else{
            Output <- paste("One or more characters does not exist, please check and try again")
            break
          }
        }
        
        # Find the corresponding letter
        for(v in 1:length(Output)){
          pos_lett = which(ref$Value == Output[v])
          Output[v] = ref$Characters[pos_lett]
        }
        Output = paste(Output, collapse = '')
      }else{
        Output = 'Please select a valid action: 1 for Encrypt or 0 for Decrypt !'
      }
    },
    
    error = function(e){
      Output = 'The message you are trying to Encrypt/Decrypt is not in the correct format, please verify and try again'
    }
    
  )
    # Output the final message Encrypted/Decrypted
    Output
}

###### Test the function ######

#####
# Encrypt
####

Message_encr = 'Hi Adri, Hi Sebas, how are you?'
Action = 0  #### ---> 0 for Encrypt, 1 for Decrypt 
Encrypted_msg = Encrypt_Decrypt(Message_encr, Action)
print(Encrypted_msg)


#####
# Decrypt
####

Message_decr = '8.00405.002512.006012.006015.007450.02486.003018.00899.00455.002514.00694.002019.009448.0238'
Action2 = 1  #### ---> 0 for Encrypt, 1 for Decrypt
Decrypted_msg = Encrypt_Decrypt(Message_decr, Action2)
print(Decrypted_msg)
