module LearnToProgram

  #  Localized short chapter titles. The chapter BODIES stay in Portuguese —
  #  only these labels and the site chrome are translated. /en shows an
  #  "em tradução" banner and falls back to the Portuguese body.
  CHAPTER_TITLES = {
    'pt' => {
      'format' => 'Página de Formatação',
      '00' => 'Iniciando', '01' => 'Números', '02' => 'Letras',
      '03' => 'Variáveis e Atribuições', '04' => 'Misturando tudo',
      '05' => 'Mais Sobre Métodos', '06' => 'Controle de Fluxo',
      '07' => 'Arrays e Iteradores', '08' => 'Escrevendo seus Próprios Métodos',
      '09' => 'Classes', '10' => 'Blocos e Procs', '11' => 'Além deste Tutorial'
    },
    'en' => {
      'format' => 'Formatting Page',
      '00' => 'Getting Started', '01' => 'Numbers', '02' => 'Letters',
      '03' => 'Variables and Assignment', '04' => 'Mixing It Up',
      '05' => 'More About Methods', '06' => 'Flow Control',
      '07' => 'Arrays and Iterators', '08' => 'Writing Your Own Methods',
      '09' => 'Classes', '10' => 'Blocks and Procs', '11' => 'Beyond This Tutorial'
    }
  }

  #  UI/chrome strings per locale.
  STRINGS = {
    'pt' => {
      site_title:     'Aprenda a Programar, por Chris Pine',
      nav_home:       'Início',
      nav_tutorials:  'Tutoriais',
      nav_current:    'Aprenda a Programar',
      skip:           'Pular para o conteúdo',
      lang_label:     'Idioma',
      menu_original:  '&laquo; o tutorial original &raquo;',
      footer_privacy: 'Privacidade',
      footer_terms:   'Termos',
      footer_cookies: 'Cookies',
      wip_html:       nil
    },
    'en' => {
      site_title:     'Learn to Program (Brazilian Portuguese edition)',
      nav_home:       'Home',
      nav_tutorials:  'Tutorials',
      nav_current:    'Learn to Program',
      skip:           'Skip to content',
      lang_label:     'Language',
      menu_original:  '&laquo; the original tutorial &raquo;',
      footer_privacy: 'Privacy',
      footer_terms:   'Terms',
      footer_cookies: 'Cookies',
      wip_html:       'This chapter is still being translated into English. For now ' \
                      'the text below is in Portuguese &mdash; for the English original, see ' \
                      'Chris Pine&#39;s <a href="http://pine.fm/LearnToProgram/">Learn to Program</a>.'
    }
  }

  def initialize (cgi)
    @cgi = cgi
    @depth = 0
    @page  = []
    @locale = (cgi.respond_to?(:locale) ? cgi.locale : nil).to_s
    @locale = 'pt' unless STRINGS.key?(@locale)

    #  'format' é uma página escondida para testar a formatação.
    @chapters = {'format'=>['Página de Formatação',          		:generateFormattingPage]}
    @chapters['00'     ] = ['Iniciando',                    		:generateSetup]
    @chapters['01'     ] = ['Números',                       		:generateNumbers]
    @chapters['02'     ] = ['Letras',                   	    	:generateLetters]
    @chapters['03'     ] = ['Variáveis e Atribuições',      		:generateVariables]
    @chapters['04'     ] = ['Misturando tudo',           		    :generateConversion]
    @chapters['05'     ] = ['Mais Sobre Métodos',   		     	  :generateMethods]
    @chapters['06'     ] = ['Controle de Fluxo',          		 	:generateFlowControl]
    @chapters['07'     ] = ['Arrays e Iteradores',           		:generateArrays]
    @chapters['08'     ] = ['Escrevendo seus Próprios Métodos', :generateDefMethod]
    @chapters['09'     ] = ['Classes',                     			:generateClasses]
    @chapters['10'     ] = ['Blocos e Procs',                		:generateBlocksProcs]
    @chapters['11'     ] = ['Além deste Tutorial',	         		:generateBeyond]
  end
  
  def getChapter (method)
    @chapters.each do |num, chapter|
      return num if (method == chapter[1])
    end
    'Main'
  end
  
  def selfLink (chap = nil)
    "/#{@locale}/index.rb?Chapter=" + (chap ? getChapter(chap) : '')
  end

  #  Current chapter number as it appears in the URL (or '' for the TOC page).
  def currentChapterParam
    (@cgi.params['Chapter'][0] || '').to_s
  end

  #  Same page in the other locale (used by the language switcher).
  def switchLocaleLink (other)
    "/#{other}/index.rb?Chapter=#{currentChapterParam}"
  end

  def localeRoot
    "/#{@locale}"
  end

  def t (key)
    STRINGS[@locale][key]
  end

  #  Localized short title for a chapter number, falling back to the PT title.
  def chapterTitle (num)
    (CHAPTER_TITLES[@locale] && CHAPTER_TITLES[@locale][num]) ||
      (@chapters[num] && @chapters[num][0])
  end
  
  def makeLink (name, methodName)
    '<a href="'+selfLink(methodName)+'">'+name+'</a>'
  end
  
  def out
    @cgi.out { @page.join("\n")+"\n" }
  end
  
  def puts (string, escapeThis=false)
    if escapeThis
      string = htmlEscape string
    end
    @page << '  '*@depth+string
  end

  #  Old-style HTML escaping: escapes &, <, >, and " but deliberately NOT the
  #  single quote. syntaxColor detects Ruby string literals by scanning for ',
  #  so ' must survive escaping. (Modern CGI.escapeHTML turns ' into &#39;,
  #  whose '#' then gets mis-parsed by syntaxColor as the start of a comment.)
  def htmlEscape (str)
    str.to_s.gsub(/[&<>"]/, '&' => '&amp;', '<' => '&lt;', '>' => '&gt;', '"' => '&quot;')
  end
  
  def escapeOutputNotInput (output)
    md = /#{INPUT}.*?#{INPUT.reverse}/.match output
    if md
      htmlEscape(md.pre_match) +
      htmlEscape(md[0]).sub(/#{INPUT}/,'<span class="L2Pinput">').sub(/#{INPUT.reverse}/,'</span>') +
      escapeOutputNotInput(md.post_match)
    else
      htmlEscape output
    end
  end
  
  def syntaxColor (str)  #  str provavelmente possui html-escaped.
    lines = str.split /\n/
    #  L2Pcomment
    #  L2Pstring
    #  L2Pnumber
    #  L2Pkeyword
    #  L2Pdefinition
    
    lines.collect! do |line|
      #line += ' '  #  para dividir... Precisamos disso?
      md = /'|#/.match line
      if md  #  Comment or string.
        syntaxColor(md.pre_match) + 
        if (md[0] == '#')
          '<span class="L2Pcomment">' + md[0] + md.post_match + '</span>'
        else  #  Big string time...
          md2 = /(.*?)(^|[^\\])((\\\\)*)'/.match md.post_match
          if (md2)
            md[0] + '<span class="L2Pstring">' + $1 + $2 + $3 +
                    '</span>' + "'" + syntaxColor(md2.post_match)
          else
            md[0]
          end
        end
      else  #  sem comentários nem string.
        keywords = %w[__FILE__ and end in or self unless __LINE__
                      begin ensure redo super until BEGIN break do
                      false next rescue then when END case else for
                      nil retry true while alias elsif if not
                      return undef yield]
        
        keywords.each do |keyword|
          line.gsub!(/(\W|^)(#{keyword})(\W|$)/) do
            $1+'<span class="L2Pkeyword">'+$2+'</span>'+$3
          end
        end
        
        ['def', 'class', 'module'].each do |keyword|
          line.gsub!(/(\W|^)(#{keyword}) +([\w?]+)/) do
            $1+'<span class="L2Pkeyword">'   +$2+'</span>'+
              ' <span class="L2Pdefinition">'+$3+'</span>'
          end
        end
        
        line.gsub!(/(^|[-{\[( ^+%*\/?;])(\d+(\.\d+)?|\.\d+)/) do
          $1+'<span class="L2Pnumber">'+$2+'</span>'
        end
        
        line
      end
    end
    
    lines.join "\n"
  end
  
  
  def input (str)
    str = htmlEscape str
    str.gsub!(/ /, '&nbsp;')
    '<span class="L2Pinput">'+str+'</span>'
  end
  
  def code (str)
    str = htmlEscape str
    str.gsub!(/ /, '&nbsp;')
    str = syntaxColor  str
    '<span class="L2Pcode">'+str+'</span>'
  end
  
  def output (str)
    str = htmlEscape str
    str.gsub!(/ /, '&nbsp;')
    '<span class="L2Pcode L2PcodeBG" style="padding-right: 3px; padding-left: 3px;">'+str+'</span>'
  end
  
  #  Essa é a parte legal...
  def executeCode (code, input)
    #  Encapsula o código para pegar erros e não ocorrer SystemExit.
    code = <<-END_CODE
      begin
        #{code}
      rescue SystemExit
      rescue Exception => error
        puts error.inspect
      end
    END_CODE
    
    strIO = StringIO.new
    
    if !input.empty?
      input = input.join("\n")+"\n"
      input = StringIO.new(input, "r")
      class << strIO; self; end.module_eval do
        ['gets', 'getc', 'read'].each do |meth|
          define_method(meth) do |*params|
            inStr = input.method(meth).call(*params)
            puts INPUT+inStr.chomp+(INPUT.reverse)  #  Echo input.
            inStr
          end
        end
      end
    end
    
    #  Passa esses métodos para strIO:
    kernelMethods = ['puts', 'putc', 'gets']
    
    # Métodos de Swap out Kernel...
    kernelMethods.each do |meth|
      Kernel.module_eval "alias __temp__tutorial__#{meth}__ #{meth}"
      Kernel.module_eval do
        define_method(meth) do |*params|
          strIO.method(meth).call(*params)
        end
      end
    end
    
    begin
      strIO.instance_eval code
    rescue Exception => error  #  Captura erros durante o parse.
      return error.inspect
    end
    
    #  ...e faz o swap de volta.
    kernelMethods.each do |meth|
      Kernel.module_eval "alias #{meth} __temp__tutorial__#{meth}__"
    end
    
    strIO.string
  end
  
  
  #  Tags (ou similar)
  
  def para (attributes = {}, &block)
    method_missing(:p, attributes, &block)
  end
  
  def prog (execute = [], remark = nil, fakeOutput = nil, &block)
    if !execute
      return progN(&block)
    end
    
    run = {:input => execute}
    run[:remark    ] = remark     if remark
    run[:fakeOutput] = fakeOutput if fakeOutput
    progN(run, &block)
  end
  
  def progN (*trialRuns)
    code = yield
    
    #  Retirando espaços em branco.
    lines = code.split $/
    numSpaces = lines[0].length - lines[0].sub(/ */, '').length
    lines.each do |line|
      line.sub!(/ {0,#{numSpaces}}/, '')
    end
    code = lines.join($/)
    
    prettyCode = syntaxColor(htmlEscape(code))
    
    #  Spit it out.
    puts '<pre class="L2PcodeBlock">'+prettyCode+'</pre>'
    
    trialRuns.each do |run|
      if run[:fakeOutput]
        puts '<pre class="L2PoutputBlock">'+htmlEscape(run[:fakeOutput])+'</pre>'
      end
      if run[:remark]
        puts '<p>'+run[:remark]+'</p>'
      end
      output = escapeOutputNotInput(executeCode(code,run[:input]))
      puts '<pre class="L2PoutputBlock">'+$/+output+'</pre>'
    end
    nil
  end
  
  #  Cria uma tag.
  def method_missing (methodSymbol, attributes = {})
    methodName = methodSymbol.to_s
    
    attribString = ''
    attributes.each do |key, val|
      raise methodName if (key.nil? || val.nil?)
      attribString += ' '+key.to_s+'="'+val+'"'
    end
    if (!block_given?)
      puts '<'+methodName+attribString+' />'
    else
      puts '<'+methodName+attribString+'>'
      @depth += 1
      blockReturn = yield
      puts blockReturn if (blockReturn.kind_of?(String))
      @depth -= 1
      puts '</'+methodName+'>'
    end
    nil
  end
  
  def self.included(base)
    base.extend(LearnToProgram::ClassMethods)
  end
  
  module ClassMethods
    def handle_request cgi
      begin
        if cgi.params['ShowTutorialCode'][0]
          tutorialSource = File.read __FILE__
          cgi.out('text/plain') { tutorialSource }
        else
          page = self.new cgi
          page.generate
          page.out
        end
      rescue Exception => e
        error_msg = <<-END_ERROR
          <html><head><title>ERRO</title></head>
          <body><h3>ERRO: envie um e-mail para o Chris ou para a Katy com o seguinte endereço</h3>
          <pre><strong>#{e.class}:  #{CGI::escapeHTML(e.message)}</strong>
          #{e.backtrace.join("\n")}
          </pre>
          </body></html>
        END_ERROR
        cgi.out { error_msg }
      end
    end
  end
end
