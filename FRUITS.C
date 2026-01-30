#include <gtk/gtk.h>
// --- Dados do Jogo ---
// Array de "frutas" (emojis como strings UTF-8)
const char *fruits[] = {"🍇", "🍊", "🍎", "🍒"};
const int NUM_FRUITS = sizeof(fruits) / sizeof(fruits[0]); // Calcula o número de frutas

// Ponteiros para os widgets GTK
GtkWidget *window;     // Janela principal
GtkWidget *grid;       // Layout em grade para organizar os widgets
GtkWidget *reel_labels[3]; // Rótulos para exibir os emojis dos carretéis
GtkWidget *spin_button; // Botão "Spin!"
GtkWidget *result_label; // Rótulo para exibir a mensagem de resultado

// --- Variáveis de Estado do Jogo ---
gboolean spinning_in_progress = FALSE; // Flag para indicar se os carretéis estão girando
guint spin_timeout_id[3] = {0, 0, 0};   // IDs dos temporizadores para cada carretel
guint check_result_timeout_id = 0;    // ID do temporizador para verificar o resultado

// --- Protótipos de Funções ---
const char* get_random_fruit(); // Retorna uma fruta aleatória
gboolean update_reel_spin(gpointer data); // Callback para animar o giro do carretel
void on_spin_button_clicked(GtkButton *button, gpointer user_data); // Callback para o clique do botão
void check_result_gtk(); // Verifica o resultado e atualiza a interface GTK

/**
 * @brief Obtém uma fruta aleatória do array de frutas.
 * @return Um ponteiro para a string (emoji) da fruta.
 */
const char* get_random_fruit() {
    return fruits[rand() % NUM_FRUITS];
}

/**
 * @brief Callback chamado repetidamente para animar o giro de um carretel.
 * @param data Ponteiro para o GtkLabel do carretel.
 * @return TRUE para continuar o temporizador, FALSE para pará-lo.
 */
gboolean update_reel_spin(gpointer data) {
    GtkWidget *reel_label = (GtkWidget *)data;
    gtk_label_set_text(GTK_LABEL(reel_label), get_random_fruit()); // Atualiza o texto do carretel

    // Continua a animação por um tempo fixo (para simular o giro)
    // A parada real é controlada por um temporizador separado ou pela lógica principal.
    // Este temporizador só para quando o carretel específico deve "parar" de girar aleatoriamente.
    // A lógica de parada sequencial é tratada no 'on_spin_button_clicked' e 'check_result_gtk'.
    return TRUE; // Continua a chamar esta função
}

/**
 * @brief Verifica o resultado do jogo (vitória ou derrota) e atualiza a mensagem na interface GTK.
 * Toca o som correspondente ao resultado (requer integração de biblioteca de áudio).
 */
void check_result_gtk() {
    const char *fruit1 = gtk_label_get_text(GTK_LABEL(reel_labels[0]));
    const char *fruit2 = gtk_label_get_text(GTK_LABEL(reel_labels[1]));
    const char *fruit3 = gtk_label_get_text(GTK_LABEL(reel_labels[2]));

    if (strcmp(fruit1, fruit2) == 0 && strcmp(fruit2, fruit3) == 0) {
        gtk_label_set_markup(GTK_LABEL(result_label), "<span foreground='green' weight='bold'>Parabéns! Você ganhou!</span>");
        // TODO: Reproduzir som de vitória aqui (ex: GStreamer)
        // Ex: play_win_sound();
    } else {
        gtk_label_set_markup(GTK_LABEL(result_label), "<span foreground='red' weight='bold'>Tente novamente!</span>");
        // TODO: Reproduzir som de derrota aqui (ex: GStreamer)
        // Ex: play_lose_sound();
    }

    gtk_widget_set_sensitive(spin_button, TRUE); // Reabilita o botão "Spin!"
    spinning_in_progress = FALSE; // Reinicia a flag de giro
}

/**
 * @brief Callback para o evento de clique do botão "Spin!".
 * Inicia o giro dos carretéis e os temporizadores para a animação e verificação do resultado.
 * @param button O botão que foi clicado.
 * @param user_data Dados do usuário (não usados neste caso).
 */
void on_spin_button_clicked(GtkButton *button, gpointer user_data) {
    if (spinning_in_progress) {
        return; // Ignora cliques se já estiver girando
    }

    spinning_in_progress = TRUE;
    gtk_widget_set_sensitive(button, FALSE); // Desabilita o botão enquanto gira
    gtk_label_set_text(GTK_LABEL(result_label), ""); // Limpa a mensagem de resultado

    // TODO: Reproduzir som de giro aqui (ex: GStreamer)
    // Ex: play_spin_sound();

    // Semente para o gerador de números aleatórios a cada giro
    srand((unsigned int)time(NULL));

    // Para cada carretel, inicia um temporizador que atualiza o emoji rapidamente
    // Simula a animação de giro. Cada carretel tem seu próprio temporizador.
    // O tempo de parada é escalonado para dar um efeito sequencial.
    for (int i = 0; i < 3; ++i) {
        // Se houver um temporizador ativo para este carretel, remove-o primeiro
        if (spin_timeout_id[i] != 0) {
            g_source_remove(spin_timeout_id[i]);
            spin_timeout_id[i] = 0;
        }
        // Adiciona um novo temporizador para atualizar o carretel a cada 50ms
        spin_timeout_id[i] = g_timeout_add(50, update_reel_spin, reel_labels[i]);

        // Agenda a parada visual de cada carretel após um certo atraso
        g_timeout_add_once(1000 + (i * 300), [](gpointer data) -> gboolean {
            GtkWidget *reel_label = (GtkWidget *)data;
            // Para o temporizador de giro deste carretel
            // Note: g_source_remove expects the ID, which is stored in spin_timeout_id[i]
            // We need a way to pass 'i' or the specific ID to this lambda or a separate function.
            // For simplicity, we'll just set the final fruit here.
            gtk_label_set_text(GTK_LABEL(reel_label), get_random_fruit());
            return G_SOURCE_REMOVE; // Remove this one-shot timeout
        }, reel_labels[i]);
    }

    // Atraso para parar os temporizadores de giro e, em seguida, verificar o resultado
    // Remove o temporizador antigo se existir para evitar chamadas duplas
    if (check_result_timeout_id != 0) {
        g_source_remove(check_result_timeout_id);
        check_result_timeout_id = 0;
    }
    // Agenda a verificação do resultado após todos os carretéis terem "parado"
    check_result_timeout_id = g_timeout_add_once(1000 + (3 * 300) + 500, [](gpointer data) -> gboolean {
        // Para os temporizadores de giro restantes
        for (int i = 0; i < 3; ++i) {
            if (spin_timeout_id[i] != 0) {
                g_source_remove(spin_timeout_id[i]);
                spin_timeout_id[i] = 0;
            }
        }
        check_result_gtk(); // Chama a função de verificação do resultado
        return G_SOURCE_REMOVE; // Remove este temporizador one-shot
    }, NULL);
}


/**
 * @brief Função de ativação principal da aplicação GTK.
 * Cria a janela, os widgets e configura o layout.
 * @param app O objeto GtkApplication.
 * @param user_data Dados do usuário (não usados neste caso).
 */
static void activate(GtkApplication *app, gpointer user_data) {
    // Cria uma nova janela GTK
    window = gtk_application_window_new(app);
    gtk_window_set_title(GTK_WINDOW(window), "Máquina Caça-Níqueis");
    gtk_window_set_default_size(GTK_WINDOW(window), 400, 300); // Tamanho inicial da janela
    gtk_window_set_position(GTK_WINDOW(window), GTK_WIN_POS_CENTER); // Centraliza a janela

    // Cria um novo layout de grade
    grid = gtk_grid_new();
    gtk_container_add(GTK_CONTAINER(window), grid);
    gtk_grid_set_row_spacing(GTK_GRID(grid), 20); // Espaçamento entre as linhas
    gtk_grid_set_column_spacing(GTK_GRID(grid), 20); // Espaçamento entre as colunas
    gtk_container_set_border_width(GTK_CONTAINER(grid), 30); // Preenchimento ao redor da grade

    // Título do jogo
    GtkWidget *title_label = gtk_label_new("<h1>Máquina Caça-Níqueis</h1>");
    gtk_label_set_use_markup(GTK_LABEL(title_label), TRUE); // Permite markup HTML
    gtk_grid_attach(GTK_GRID(grid), title_label, 0, 0, 3, 1); // Anexa na linha 0, colunas 0-2

    // Cria e anexa os rótulos dos carretéis
    for (int i = 0; i < 3; ++i) {
        reel_labels[i] = gtk_label_new(get_random_fruit()); // Define um fruto inicial
        gtk_label_set_markup(GTK_LABEL(reel_labels[i]), g_strdup_printf("<span font_desc='Arial Bold 48'>%s</span>", gtk_label_get_text(GTK_LABEL(reel_labels[i]))));
        gtk_widget_set_size_request(reel_labels[i], 100, 100); // Define um tamanho fixo para o carretel
        gtk_widget_set_halign(reel_labels[i], GTK_ALIGN_CENTER); // Centraliza horizontalmente
        gtk_widget_set_valign(reel_labels[i], GTK_ALIGN_CENTER); // Centraliza verticalmente
        
        // Estilo da borda e fundo simulado (GTK não tem border-radius ou box-shadow simples)
        // Isso é mais complexo em GTK, geralmente feito com CSS ou draw functions.
        // Por simplicidade, vamos apenas definir um fundo para o widget aqui.
        GtkCssProvider *provider = gtk_css_provider_new();
        gtk_css_provider_load_from_data(provider,
                                        "label {"
                                        "  background-color: #e9e9e9;"
                                        "  border: 2px solid #cccccc;"
                                        "  border-radius: 8px;" // border-radius só funciona em GTK 3.20+ e pode precisar de GtkDrawingArea
                                        "  padding: 5px;"
                                        "}", -1, NULL);
        GtkStyleContext *context = gtk_widget_get_style_context(reel_labels[i]);
        gtk_style_context_add_provider(context, GTK_STYLE_PROVIDER(provider), GTK_STYLE_PROVIDER_PRIORITY_APPLICATION);
        g_object_unref(provider);

        gtk_grid_attach(GTK_GRID(grid), reel_labels[i], i, 1, 1, 1); // Anexa na linha 1, colunas 0, 1, 2
    }

    // Cria e anexa o botão "Spin!"
    spin_button = gtk_button_new_with_label("Spin!");
    g_signal_connect(spin_button, "clicked", G_CALLBACK(on_spin_button_clicked), NULL);
    gtk_widget_set_size_request(spin_button, 150, 50); // Define um tamanho para o botão
    
    // Estilo do botão (simulado)
    GtkCssProvider *button_provider = gtk_css_provider_new();
    gtk_css_provider_load_from_data(button_provider,
                                    "button {"
                                    "  background-color: #4CAF50;"
                                    "  color: white;"
                                    "  font-size: 20px;"
                                    "  border-radius: 5px;"
                                    "  padding: 15px 30px;"
                                    "}"
                                    "button:hover {"
                                    "  background-color: #45a049;"
                                    "}", -1, NULL);
    GtkStyleContext *button_context = gtk_widget_get_style_context(spin_button);
    gtk_style_context_add_provider(button_context, GTK_STYLE_PROVIDER(button_provider), GTK_STYLE_PROVIDER_PRIORITY_APPLICATION);
    g_object_unref(button_provider);

    gtk_grid_attach(GTK_GRID(grid), spin_button, 0, 2, 3, 1); // Anexa na linha 2, colunas 0-2

    // Cria e anexa o rótulo de resultado
    result_label = gtk_label_new("");
    gtk_label_set_use_markup(GTK_LABEL(result_label), TRUE);
    gtk_grid_attach(GTK_GRID(grid), result_label, 0, 3, 3, 1); // Anexa na linha 3, colunas 0-2

    gtk_widget_show_all(window); // Exibe todos os widgets na janela
}

/**
 * @brief Função principal da aplicação.
 * Inicializa GTK e executa o loop principal de eventos.
 * @param argc Número de argumentos da linha de comando.
 * @param argv Array de strings com os argumentos da linha de comando.
 * @return O código de saída da aplicação.
 */
int main(int argc, char **argv) {
    GtkApplication *app;
    int status;

    // Inicializa o gerador de números aleatórios com o tempo atual
    srand((unsigned int)time(NULL));

    // Cria um novo objeto GtkApplication
    app = gtk_application_new("org.gtk.slotmachine", G_APPLICATION_FLAGS_NONE);
    // Conecta a função 'activate' ao sinal "activate" da aplicação
    g_signal_connect(app, "activate", G_CALLBACK(activate), NULL);
    // Executa a aplicação
    status = g_application_run(G_APPLICATION(app), argc, argv);
    g_object_unref(app); // Libera o objeto da aplicação

    return status;
}
