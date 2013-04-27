//
//  RankingCampeonatoTableViewController.m
//  PokerGames
//
//  Created by Fabiano Rosa on 23/04/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

#import "RankingCampeonatoTableViewController.h"
#import "AppDelegate.h"
#import "Jogador.h"
#import "Liga.h"
#import "Campeonato.h"
#import "AFAppDotNetAPIClient.h"
#import "MBProgressHUD.h"
#import "RankingCampeonatoJogadorCell.h"
#import <QuartzCore/QuartzCore.h>
#import "ADVTheme.h"

@interface RankingCampeonatoTableViewController () {
    NSArray *arRanking;
}

@end

@implementation RankingCampeonatoTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (AppDelegate *)appDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // configura o header
    id <ADVTheme> theme = [ADVThemeManager sharedTheme];
    [self.viewHeader setBackgroundColor:[UIColor colorWithPatternImage:[theme viewBackground]]];
    self.viewHeader.layer.borderColor = [UIColor grayColor].CGColor;
    self.viewHeader.layer.borderWidth = 0.7f;
    
    // botao de configuracoes
    UIImage* imgConfig = [UIImage imageNamed:@"NavBarIconLauncher.png"];
    UIBarButtonItem *btnConfig = [[UIBarButtonItem alloc]
                                   initWithImage:imgConfig
                                   style:UIBarButtonItemStyleBordered
                                   target:self
                                   action:@selector(configAction)];
    self.navigationItem.rightBarButtonItem = btnConfig;
    
    // botao de logout
    UIImage* imgLogout = [UIImage imageNamed:@"NavBarIconLogout.png"];
    UIBarButtonItem *btnLogout = [[UIBarButtonItem alloc]
                                  initWithImage:imgLogout
                                  style:UIBarButtonItemStyleBordered
                                  target:self
                                  action:@selector(logoutAction)];
    self.navigationItem.leftBarButtonItem = btnLogout;
    
    // adiciona controle de refresh
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Puxe para atualizar"];
    [refresh addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
}

-(IBAction)configAction
{
    
}

-(IBAction)logoutAction
{
    [Jogador excluirTodosJogadoresDependencias];
    [self performSegueWithIdentifier:@"LoginJogador" sender:self];
}

-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    // remove o botão Back de navegação
    //self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.hidesBackButton = YES;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = [self.appDelegate jogadorLogin].liga.campeonato.apelido;
    [self buscaRanking]; 
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return arRanking.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellRanking";
    RankingCampeonatoJogadorCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSDictionary *rankingJogador = arRanking[indexPath.row];
    cell.row = indexPath.row;
    cell.dados = rankingJogador;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (void)buscaRankingCampeonatosWithBlock:(NSNumber *)idLiga
                                  idCampeonato:(NSNumber *)idCampeonato
            constructingBodyWithBlock:(void (^)(NSArray *ranking, NSError *error))block
{
    
    NSString *path = [NSString stringWithFormat:@"Campeonatos.svc/Ranking/%@/%@", idLiga, idCampeonato];
    //NSLog(@"Path: %@", path);
    
    [[AFAppDotNetAPIClient sharedClient] getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSArray *postsFromResponse = [JSON valueForKeyPath:@"RankingResult"];
        if (block) {
            block(postsFromResponse, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block([NSArray array], error);
        }
    }];
}

- (void) buscaRanking {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Buscando ranking";
    
    Jogador *jogadorLogin = [self.appDelegate jogadorLogin];
    //NSLog(@"Busca campeonatos da liga %@", jogadorLogin.idJogador);
    
    // busca lista de campeonatos da liga
    [self buscaRankingCampeonatosWithBlock:jogadorLogin.liga.idLiga
                              idCampeonato:jogadorLogin.liga.campeonato.idCampeonato
                 constructingBodyWithBlock:^(NSArray *ranking, NSError *error) {
                     
         [hud hide:YES];
         
         if (error) {
             [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Erro", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
         } else {
             // ranking do campeonato
             //NSLog(@"Ranking: %@", ranking );
             arRanking = ranking;
             
             // atualiza table
             [self.tableView reloadData];
         }
         
     }];
}


-(void) refreshView:(UIRefreshControl *) refresh
{
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Atualizando dados..."];
    
    Jogador *jogadorLogin = [self.appDelegate jogadorLogin];
    //NSLog(@"Busca campeonatos da liga %@", jogadorLogin.idJogador);
    
    // busca lista de campeonatos da liga
    [self buscaRankingCampeonatosWithBlock:jogadorLogin.liga.idLiga
                              idCampeonato:jogadorLogin.liga.campeonato.idCampeonato
                 constructingBodyWithBlock:^(NSArray *ranking, NSError *error) {
                     
     if (error) {
         [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Erro", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
     } else {
         // ranking do campeonato
         //NSLog(@"Ranking: %@", ranking );
         arRanking = ranking;
         
         // atualiza table
         //[self.tableView reloadData];
     }
     
    }];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"d MMM, h:mm a"];
    NSString *lastUpdate = [NSString stringWithFormat:@"Última atualização em %@", [formatter stringFromDate:[NSDate date]]];
    
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdate];
    [refresh endRefreshing];
}
@end