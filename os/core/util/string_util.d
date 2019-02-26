/**
 * Authors: initkfs
 */
module os.core.util.string_util;

//TODO template
size_t indexOfNot(char[] str, char notChar){
    size_t startIndex;
    for(auto i = 0; i < str.length; i++){
        char ch = str[i];
        if(ch != notChar){
            break;
        }else {
            startIndex++;
        }
    }
    return startIndex;
}

size_t indexOfNotZeroChar(char[] str){
    return indexOfNot(str, '0');
}