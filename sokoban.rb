# coding: utf-8
#
class GameMap 
    
    attr_accessor :b_map, :num_level, :max_level
    attr_reader   :out_p, :comb, :akt, :a_file, :cur_box
    
    def initialize      # Инициализация объекта =======================
        @map = []       # массив "объектов" на поле
        @s_map = 0      # Размер карты +1
        @boy_ = 0       # координата человека
        @x_map = 0      # размер поля по горизонтали
        @y_map = 0      # размер поля по вертикали
        @b_map = 0      # количество контейнеров на уровне
        @h_map = 0      # количество домов для контейнеров на уровне
        @out_p = nil    # причина аварийного завешения
        @max_level = 50 # максимальный уровень
        @comb = ''
        @num_level      # Переменная - номер уровня
        @a_file = ''    # Текст уровня из файла
        @akt = false    # Признан выпролненного хода
        @cur_box = false# Признак хода с толканием контейнера
        @hh = { 
            '00' => '20', # просто ход (+1) свободно
            '03' => '23', # просто ход (+1) свободно
            '30' => '50', # просто ход (+1) свободно (дом)
            '33' => '53', # просто ход (+1) свободно (дом)
            
            '07' => '27', # просто ход (+1) ход к контейнеру
            '04' => '24', # просто ход (+1) ход к контейнеру
            '37' => '57', # просто ход (+1) ход к контейнеру (дом,дом)
            '34' => '54', # просто ход (+1) ход к контейнеру (дом,дом)
            
            '08' => '28', # просто ход (+1) подойдём к стене
            '38' => '28', # просто ход (+1) подойдём к стене
                       
            '40' => '04', # толкнуть контейнер (+2)
            '43' => '07', # толкнуть контейнер (+2)
            '70' => '34', # толкнуть контейнер (+2)
            '73' => '37', # толкнуть контейнер (+2)
            
            '88' => '--', # впереди стена (-)
            '8'  => '--', # впереди стена (-)
            '87' => '--', # впереди стена (-)
            '84' => '--', # впереди стена (-)
            '80' => '--', # впереди стена (-)
            '83' => '--', # впереди стена (-)
            
            '44' => '--', # два контейнера (-)
            '77' => '--', # два контейнера (-)
            '47' => '--', # два контейнера (-)
            '74' => '--', # два контейнера (-)
            
            '48' => '--', # контейнер у стены (-)
            '78' => '--'  # контейнер у стены (-)
        }
    end
    
    def input_level                             # Вввод уровня карты ==
        
        if @map.size == 0  # Если начало игры, то 00 уровень.
            @map << -1     # Далее будет += 1 и получим 00
        end

        puts
        print "Выберите уровень (0 - #{@max_level}) "
        @num_level = gets.strip.to_i 
        
        if @num_level == ''  # Ничего не ввели, то следующий уровень
            if @map[0] == @max_level
                puts "Все уровни пройдены!"
                exit
            end
            @num_level = (@map[0] + 1)
        end
        
    end
        
    def read_level                    # Чтение карты уровня из файла ==

        if @num_level.to_s.size == 1
            number = '0' + @num_level.to_s
        else
            number = @num_level.to_s
        end
                            # Формирование имени файла-уровня
        file_data_level = 'data/level_' + number + '.txt'
        
        row_lines = []      
                            # Открываем файл для считывания карты
        input = File.open(file_data_level, 'r')

        while (line = input.gets)       # Считывает строчку из файла
            
            row_lines << line.chomp     # Добавляем её в массив
        end

        input.close         # Закрывает файл

        @map = []
        @map << @num_level   # Запоминаем номер уровня в массив.
        
        if $debug >= 2      ##########################################     
            puts row_lines  ##########################################
            gets            ##########################################
        end
                            # Обработка row_lines
        @x_map = 0          # Максимальная длинна строки = 0
        @y_map = 0          # Количество строк = 0 
        row_lines.each do |line|  # перебираем строчки по очереди

            # Запомнить новую макс.длину
            #                        Если дилина этой строки ещё больше 
            @x_map = line.size if line.size > @x_map  

            @y_map +=1                  # Количество строк в карте (+1)

        end
        
        if $debug >= 1                  ###############################
            puts "x_map = #{@x_map}"    ###############################
            puts "y_map = #{@y_map}"    ###############################
            gets                        ###############################
        end                             ###############################

        @a_file = ''       # Очищаем переменную для ввода нового уровня
        
        row_lines.each do |line|
        
            @a_file += line + (' ' * (@x_map - line.size))
            
        end
        
        if $debug >= 1                      ###########################
            print "Размер @a_file = "       ###########################
            puts @a_file.size               ###########################
            gets                            ###########################
        end                                 ###########################
        
    end
    
    def braun opt       # ОБРАБОТКА ХОДА. =============================
        
        @out_p = nil
        pl_0 = @boy_    # Место человека => pl_0
        
        # ______________________________________Make coordinates moving
        if    opt[:director] == 'UP'    # Если нужно ВВЕРХ 
            pl_1 = @boy_ - @x_map       # Рассчитаем index поля сверху
            pl_2 =  pl_1 - @x_map       # Рассчитаем index ещё выше
            
        elsif opt[:director] == 'DOWN'  # Если нужно ВНИЗ
            pl_1 = @boy_ + @x_map       # Рассчитаем index поля снизу 
            pl_2 =  pl_1 + @x_map       # Рассчитаем index ещё ниже
            
        elsif opt[:director] == 'LEFT'  # Если нужно ВЛЕВО
            pl_1 = @boy_ - 1            # Рассчитаем index поля слева
            pl_2 =  pl_1 - 1            # Рассчитаем index поля за ним
            
        elsif opt[:director] == 'RIGHT' # Если нужно ВПРАВО
            pl_1 = @boy_ + 1            # Рассчитаем index поля справа
            pl_2 =  pl_1 + 1            # Рассчитаем index поля за ним
            
        else
            # puts "New comand"
            @out_p = "Sorry ...  - his director is not found."
            return
        end
        
        # Получаем комбинацию полей для движения:
        #    pl_0  ->    pl_1   ->   pl_2
        # а точнее вот так: @map[pl_0] => @map[pl_1] => @map[pl_2]
        
        @comb = @map[pl_1].to_s + @map[pl_2].to_s
        @akt = true      # перед началом проверки = "ход возможен!"
                       
        if @hh[comb] == '--'
            @out_p = "No action '#{comb}' - combination."
            @akt = false # Здесь меняем на " Ход НЕВОЗМОЖЕН"
            
            if $debug >= 2                                  ###########
                puts @out_p                                 ###########
                gets                                        ###########
            end                                             ###########
            
        elsif @comb=='40' || @comb=='43' || @comb=='70' || @comb=='73'
            # Двигаем контейнер в ячейку PL-2 из PL-1
            @map[pl_2] += 4     # pl2 + box
            @map[pl_1] -= 4     # pl1 - box
            @cur_box = true     # Толкаем контейнер (нужно для Back)
                                            
            # Двигаем человечка в ячейку PL-1 из PL-0
            @map[pl_1] += 2     # pl1 + man
            @map[pl_0] -= 2     # boy - man
            
            @boy_ = pl_1
            @out_p = "Push action '#{@comb}' - combination."
            
            if $debug >= 2                                  ###########
                puts @out_p                                 ###########
                gets                                        ###########
            end                                             ###########
            
        else
            # Двигаем человечка в ячейку PL-1 из PL-0
            @map[pl_1] += 2     # pl1 + man
            @map[pl_0] -= 2     # boy - man
            @cur_box = false    # НЕ Толкаем контейнер (нужно для Back)
                                       
            @boy_ = pl_1
            @out_p = "Step action '#{@comb}' - combination."

            if $debug >= 2                                  ###########
                puts @out_p                                 ###########
                gets                                        ###########
            end                                             ###########
            
        end
          
    end
    
    def out_map         # Вывод карты на экран. =======================
    
        j = 1 
        puts '(Q)uit, (R)etry, (N)ext_level, (B)ack, (M)enu.'
        puts '----------------------------------------------'
        puts "  Уровень #{@map[0]}    Контейнеров #{@b_map} "
        puts 
        
        1.upto(@y_map) do |y|
                
            1.upto(@x_map) do |x|
                        
                i = x + (y-1) * @x_map # Вычисляем индекс по координ.
                
                if    @map[i] == 8      # Стена
                        print "XX"
                    
                elsif @map[i] == 2      # Человек
                        print "@@"
                    
                elsif @map[i] == 5      # Человек
                        print "@@"
                        
                elsif @map[i] == 0      # Пустота
                        print "  "
                    
                elsif @map[i] == 3      # Дом
                        print " ."
                        
                elsif @map[i] == 4      # Контейнер
                        print "[]"
                        
                elsif @map[i] == 7      # Контейнер в Дому
                        print "()"    
                    
                else              # .. неизвестный зверь ..
                        print "??"
                end 
                j += 1
            end

            print "\n"  # Закончилась строка вывода, переводим курсор
            j = 1       # "Обнуляем" счётчик места в строке.
                
        end
    
    end

    def contr_size      # Проверка целостности карты. =================
        @s_map = @map.size

       if $debug >= 2                                       ###########
        @map.each_with_index do |item, index|               ###########
            if index == 0                                   ###########
                print "Lrvel = @map[0] = #{item}"           ###########
            else                                            ###########
                print "#{item}"                             ###########
            end                                             ###########
                                                            ###########
            puts "-end line" if index % @x_map == 0         ###########
                                                            ###########
        end                                                 ###########
                puts @out_p                                 ###########
                gets                                        ###########
       puts "123456789012345678"                            ###########
       gets                                                 ###########
       end                                                  ###########
                                                            ###########        
        if @s_map != @x_map * @y_map +1 
            puts "Размер массива не соответствует размеру карты"
            puts "#{@s_map} = #{@x_map} * #{@y_map} + 1 "
            gets
        end    
        if @b_map != @h_map
            puts "Количесто контейнеров не равно количеству мест."
            puts " Контенеров: #{@b_map},    мест под них: #{@h_map}."
            gets
        end
    end
    
    def in_data         # Заполнение данными карты. ===================
        lev = ''        # 
        xlev = ''       # 
        ylev = ''       # 
        boxl = ''       # 
        x = 0
        xm = @x_map

        @h_map = @b_map = 0
        
        @a_file.each_char.with_index do |ch, i|

            x += 1 
               
            case ch
                
                when '@' then           # Человек
                    @map << 2                   
                    @boy_ = @map.size - 1

                when 'o' then           # Контейнер
                    @map << 4   
                    @b_map += 1 

                when '.' then           # Дом 
                    @map << 3 
                    @h_map += 1

                when ' ' then           # Пустота 
                    @map << 0  

                when '#' then           # Стена
                    @map << 8                  
            
            end
        end

        if $debug >= 2                                              ###
        puts "lev = #{lev}  x = #{xlev}  y = #{ylev} K = #{boxl}"   ###
        @map.each { |item| print "#{item}"}                         ###
        gets                                                        ###
        end                                                         ###

        if $debug >= 3                                      ###########
            @map.each_with_index do |item, i|               ###########
               print "#{item},"                             ###########
               puts "" if (i) % @x_map == 0                 ###########
            end                                             ###########
        end                                                 ###########
        
        if $debug >= 2                                      ###########
            puts "Уровень в @map[0] = #{@map[0]}"           ###########
            puts "@x_map = #{@x_map}"                       ###########
            puts "@y_map = #{@y_map}"                       ###########
            puts "Контейнеры @b_map = #{@b_map}"            ###########
            gets                                            ###########
        end                                                 ###########
        
    end
    
    def box             # Расчёт количества оставшихся контейнеров. ===
        @b_map = 0      
        @map.each_with_index do |item, i|
                @b_map += 1 if item == 4 && i != 0
        end
    end
    
    def back opt        # Обратный ход. ===============================
    pl_1 = @boy_ 
    # ______________________________________Make coordinates moving
        if    opt[:director] == 'UP'
            pl_0 = @boy_ + @x_map
            pl_2 = @boy_ - @x_map
            
        elsif opt[:director] == 'DOWN'
            pl_0 = @boy_ - @x_map
            pl_2 = @boy_ + @x_map
            
        elsif opt[:director] == 'LEFT'
            pl_0 = @boy_ + 1
            pl_2 = @boy_ - 1
            
        elsif opt[:director] == 'RIGHT'
            pl_0 = @boy_ - 1
            pl_2 = @boy_ + 1
        end
        if opt[:boxer] == true
            @map[pl_2] -= 4
            @map[pl_1] += 4
        end
        @map[pl_1] -= 2
        @map[pl_0] += 2
        @boy_ = pl_0
    end
end

def getchar 
         system("stty raw -echo") # Прямой ввод без эхо-контроля.
         char = STDIN.getc
         system("stty -raw echo") # Восстановить режим терминала.
         char
end


def menu_out
    puts '============================================================='
    puts '(Q)uit - выход из игры.      (N)ext level - Следующий уровень'
    puts '(R)etry - снова начать       (B)ack - шаг назад  '
    puts '============================================================='
    puts 
    puts '________________ У П Р А В Л ЕН Н И Е  ______________________'
    puts '                       ВВЕРХ'
    puts '                        (S)'
    puts '       <= ВЛЕВО - (Z)         (C) - ВПРАВО =>'
    puts '                        (X)'
    puts '                       ВНИЗ.'
    puts '============================================================='
    
end

# =====================================================================
#                                 
# =====================================================================
 

system('clear')          # Очистка экрана

menu_out
$debug = 0               # Уровень отладки (1, 2, 3) (0 - нет отладки)
 
map_games = GameMap.new
map_games.input_level
map_games.read_level
map_games.in_data
map_games.contr_size

p = 1
t = 0
mas_action = []
mas_b = []

loop do                    # ОСНОВНАЯ ПЕТЛЯ ПРОГРАММЫ

    map_games.box               # Считаем контейнеры не на месте.
    system('clear')             # Очистка экрана
   
                                # Выводим сервисное сообщение
    puts "#{map_games.akt} = #{map_games.out_p}" if $debug >= 1
                             
                                # Выводим карту
    map_games.out_map

    if map_games.b_map == 0
        puts "Good!"
        gets
        map_games.input_level
        map_games.read_level
        map_games.in_data
        map_games.contr_size
        p = 1
        t = 0
        mas_action =[]
        mas_b = []
        system('clear')
        puts
        map_games.out_map   
    end   
    
    if $debug >= 3
        mas_action.each_with_index {|item, i| puts "#{i} - #{item}"}
        gets
    end
    
    t += 1
    puts 
    puts "Попытка #{p}    Ход № #{t}."
    print "     Введите (s,x,z,c) => "
    kl = ''
    
    while kl == ''
        kl = getchar.capitalize
    end
    
    action_ = 'UP' if kl == 'S'
    action_ = 'DOWN' if kl == 'X'
    action_ = 'LEFT' if kl == 'Z'
    action_ = 'RIGHT' if kl == 'C'

    if $debug == 2
        puts "Начата кнопка #{kl}"
        gets
    end

    if (kl == 'B' || kl == ' ') && mas_action.size != 0
        map_games.back :director => mas_action[-1], :boxer => mas_b[-1]
        mas_action.pop
        mas_b.pop
        
    elsif kl == 'M'                 # Меню
        system('clear')
        menu_out
        puts "Для продолжения нажмите Пробел или Enter"
        gets
        
    elsif kl == 'N'                 # Следующий уровень
    
        if $debug >=2                                       ###########
            puts                                            ###########
            puts map_games.num_level                        ###########
            puts map_games.max_level                        ###########
            gets                                            ###########
        end                                                 ###########
        
        if map_games.num_level < map_games.max_level
            map_games.num_level += 1 
            map_games.read_level
            map_games.in_data
            map_games.contr_size
            p = 1
            t = 0
            mas_action =[]
            mas_b = []
            system('clear')
            puts
            map_games.out_map
        else
            puts "Это максимальный уровень"
            sleep 0.3    
        end
           
    elsif kl == 'Q'                 # Выход из игры
        break
        
    elsif kl == 'R'                 # Зашрузить с начала уровень
        map_games.read_level
        map_games.in_data
        map_games.contr_size
        p = 1
        t = 0
        mas_action =[]
        mas_b = []
        
    elsif kl=='S' || kl=='X' || kl=='Z' || kl=='C' # Передвижение (ХОД)
        map_games.braun :director => action_, :comb => ''
        if map_games.akt
            mas_action << action_        # Запомним направление
            mas_b << map_games.cur_box   # Запомним наличие контейнера
        end
        
    else
        t -= 1
        map_games.akt == false
        
    end
end

puts 
puts "GAME OVER!"
