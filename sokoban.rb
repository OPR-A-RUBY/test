# coding: utf-8
#
class GameMap 
    
    attr_accessor :b_map
    attr_reader   :out_p, :comb, :akt, :a_file, :cur_box
    
    def initialize      # Инициализация объекта =======================
        @map = []       # массив "объектов" на поле
        @s_map = 0      # Размер карты +1
        @boy_ = 0       # координата человека
        @x_map = 0      # размер поля по горизонтали
        @y_map = 0      # размер поля по вертикали
        @b_map = 0      # количество контейнеров на уровне
        @out_p = nil    # причина аварийного завешения
        @comb = ''
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
    
    def read_level      # Выбор уровня, чтение карты уровня из файла ==
        
        if @map.size == 0  # Есди начало игры, то 00 уровень.
            @map << -1     # Далее будет += 1 и получим 00
        end
        
        print "Выберите уровень "
        num_level = gets.strip 
        
        if num_level == ''  # Ничего не ввели, то следующий уровень
            num_level = (@map[0] + 1).to_s
        end
                            # Получение двух зхнаков уровня
        num_level = '0' + num_level if num_level.size == 1
                            # Формирование имени файла-уровня
        file_data_level = 'data/level_' + num_level + '.txt'
                            # Чтение карты уровня
        @a_file = File.open(file_data_level, 'r'){ |file| file.read }
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
        # 
        # а точнее вот так:
        #  
        #   @map[pl_0] => @map[pl_1] => @map[pl_2]
        
        @comb = @map[pl_1].to_s + @map[pl_2].to_s
        @akt = true      # перед началом проверки = "ход возможен!"
                       
        if @hh[comb] == '--'
            @out_p = "No action '#{comb}' - combination."
            @akt = false # Здесь меняем на " Ход НЕВОЗМОЖЕН"
            ### puts @out_p
            ### gets        
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
            
            ### puts @out_p
        else
            # Двигаем человечка в ячейку PL-1 из PL-0
            @map[pl_1] += 2     # pl1 + man
            @map[pl_0] -= 2     # boy - man
            @cur_box = false    # НЕ Толкаем контейнер (нужно для Back)
                                       
            @boy_ = pl_1
            @out_p = "Step action '#{@comb}' - combination."
            ### puts @out_p
        end
          
    end
    
    def out_map         # Вывод карты на экран. =======================
    
        def pr_line     # Вывод полосы "+++...+++" на экран (расчётное)
            print " +-"
            (@x_map*2).times {print "-"} 
            puts "-+ " 
        end
    
        j = 1 
        
        pr_line                                # верхняя линия окна
        puts "  Уровень #{@map[0]}    Контейнеров #{@b_map} "
        pr_line                                # верхняя линия рамки 
        
        1.upto(@y_map) do |y|
                
            print " |X"                 # Рамка в начале строки
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
            print "X| " # Рамка в конце строки
            print "\n"  # Закончилась строка вывода, переводим курсор
            j = 1       # "Обнуляем" счётчик места в строке.
                
        end
        pr_line   # нижняя линия рамки
    
    end

    def contr_size      # Проверка целостности карты. =================
            @s_map = @map.size
            1.upto(@s_map) do |i|
                if @map[i] == 9
                    puts "Неизвестный символ в карте."
                end
            end
            if @s_map != @x_map * @y_map + 1
            puts "Размер массива не соответствует размеру карты"
            puts "#{@s_map} = #{@x_map} * #{@y_map} + 1 "
            gets
        end
    end
    
    def in_data         # Заполнение данными карты. ===================
        lev = ''
        xlev = ''
        ylev = ''
        boxl = ''
        @map = []
        a_file.each_char.with_index do |ch, i|
            if i <= 2                   # Номер уровня
                lev = lev + ch
            elsif i >= 4 && i <= 6       # Размер карта Х
                xlev = xlev + ch
            elsif i >= 8 && i <=10       # Размер карта У
                ylev = ylev + ch
            elsif i >=12 && i <= 14      # Количество контейнеров 
                boxl = boxl + ch
            elsif i == 15
                @map << lev.to_i
            elsif i == 3 || i == 7 || i == 11
                sleep 0
            elsif ch == '@'
                @map << 2 
                @boy_ = @map.size - 1
            else 
                @map << 0 if ch == ' '  
                @map << 8 if ch == '#'    
                @map << 4 if ch == 'o'
                @map << 3 if ch == '.'
            end
        end
        @x_map = xlev.to_i
        @y_map = ylev.to_i
        @b_map = boxl.to_i
        
        ###[M V-puts "lev = #{lev}  x = #{xlev}  y = #{ylev} K = #{boxl}"
        ###@map.each { |item| print "#{item}"}
        ###gets
        
        ### @map.each_with_index do |item, i|
        ###    print "#{item},"
        ###    puts "" if (i) % @x_map == 0
        ###end
        
        ###puts "#{@map[0]} = #{@x_map} = #{@y_map} = #{@b_map}"
        ###gets
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
    puts '(Q)uit - выход из игры.      (L)oad - загрузить новый уровень'
    puts '(N)ew  - снова начать        (B)ack - шаг назад'
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


system('clear')             # Очистка экрана

menu_out
 
map_games = GameMap.new
map_games.read_level
map_games.in_data
map_games.contr_size

p = 1
t = 0
mas_action = []
mas_b = []
loop do 

    map_games.box               # Считаем контейнеры не на месте.
    system('clear')             # Очистка экрана
    puts "#{map_games.akt} = #{map_games.out_p}" # Выводим сервисное сообщение
    map_games.out_map           # Выводим карту

    if map_games.b_map == 0
        puts "Good!"
        gets
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
    
    ### mas_action.each_with_index {|item, i| puts "#{i} - #{item}"}
    t += 1
    print "Попытка #{p}    Ход № #{t}.  Введите (s,x,z,c) => "
    kl = ''
    while kl == ''
        kl = getchar.capitalize
    end
    
    action_ = 'UP' if kl == 'S'
    action_ = 'DOWN' if kl == 'X'
    action_ = 'LEFT' if kl == 'Z'
    action_ = 'RIGHT' if kl == 'C'
    
    puts kl
    if (kl == 'B' || kl == ' ') && mas_action.size != 0
        map_games.back :director => mas_action[-1], :boxer => mas_b[-1]
        mas_action.pop
        mas_b.pop
    elsif kl == 'M'
        system('clear')
        menu_out
        puts "Для продолжения нажмите Пробел или Enter" 
        gets
    elsif kl == 'N'
        map_games.in_data 
        map_games.contr_size
        p += 1
        t = 0
        mas_action =[]
    elsif kl == 'Q'
        break
    elsif kl == 'L'
        map_games.read_level
        map_games.in_data
        map_games.contr_size
        p = 1
        t = 0
        mas_action =[]
        mas_b = []
    elsif kl=='S' || kl=='X' || kl=='Z' || kl=='C'
        map_games.braun :director => action_, :comb => ''

        if map_games.akt
            mas_action << action_        # Запомним направление
            mas_b << map_games.cur_box   # Запомним насичие контейнера
        end
    else
        t -= 1
        map_games.akt == false
    end
end

puts "GAME OVER!"
