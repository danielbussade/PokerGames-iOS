//
//  PerfilJogadorViewController.m
//  PokerGames
//
//  Created by Fabiano Rosa on 03/05/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

#import "PerfilJogadorViewController.h"
#import "ECSlidingViewController.h"
#import "MenuViewController.h"
#import "ADVTheme.h"
#import "MBProgressHUD.h"
#import "UIImageView+AFNetworking.h"

@interface PerfilJogadorViewController () {
    NSDictionary *dadosPerfilJogador;
}

@end

@implementation PerfilJogadorViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // configura o header
    id <ADVTheme> theme = [ADVThemeManager sharedTheme];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[theme viewBackground]]];
    
    [self.btnOpcoes setBackgroundImage:[theme colorButtonBackgroundForState:UIControlStateNormal] forState:UIControlStateNormal];
    [self.btnOpcoes setBackgroundImage:[theme colorButtonBackgroundForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];

    // verifica se foi chamado do menu
    if (!self.idJogadorParametro) {
        // botao de configuracoes
        UIBarButtonItem *btnMenu = [[UIBarButtonItem alloc]
                                    initWithImage:[PokerGamesUtil menuImage]
                                    style:UIBarButtonItemStyleBordered
                                    target:self
                                    action:@selector(configAction)];
        self.navigationItem.leftBarButtonItem = btnMenu;
    }
    
    // adiciona canto arredonado
    self.imgViewFoto.layer.cornerRadius = 5.0;
    self.imgViewFoto.layer.masksToBounds = YES;
    
    // adiciona borda
    self.imgViewFoto.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.imgViewFoto.layer.borderWidth = 1.0;
    
    [self buscaPerfilJogador];
}

-(IBAction)configAction
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // verifica se foi chamado do menu
    if (!self.idJogadorParametro) {
        if (![self.slidingViewController.underLeftViewController isKindOfClass:[MenuViewController class]]) {
            self.slidingViewController.underLeftViewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
        }
        
        [self.navigationController.view addGestureRecognizer:self.slidingViewController.panGesture];        
    }
}

-(IBAction)opcoesPressed:(id)sender {
    // Create the sheet without buttons
    UIActionSheet *sheet = [[UIActionSheet alloc]
                            initWithTitle:nil
                            delegate:self
                            cancelButtonTitle:nil
                            destructiveButtonTitle:nil
                            otherButtonTitles:nil];
    
    // adiciona os botoes
    if (![self.lblTelefone.text isEqualToString:@""]) {
        [sheet addButtonWithTitle:@"Telefonar"];
    }
    
    if (![self.lblEmail.text isEqualToString:@""]) {
        [sheet addButtonWithTitle:@"Enviar e-mail"];
    }
    
    [sheet addButtonWithTitle:@"Adicionar aos contatos"];
    sheet.cancelButtonIndex = [sheet addButtonWithTitle:@"Cancelar"];
    
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    // Get the name of the current pressed button
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if  ([buttonTitle isEqualToString:@"Telefonar"]) {
        // efetua ligacao para o numero do cadastro
        UIDevice *device = [UIDevice currentDevice];
        if ([[device model] isEqualToString:@"iPhone"] ) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", self.lblTelefone.text]]];
        }
    } else if ([buttonTitle isEqualToString:@"Enviar e-mail"]) {
        MFMailComposeViewController *mailer = [[PokerGamesFacade sharedInstance] enviaEmailJogador:self.lblEmail.text delegate:self];
        if (mailer) {
            // ipad: mailer.modalPresentationStyle = UIModalPresentationPageSheet;
            [self presentViewController:mailer animated:TRUE completion:nil];   
        }
    } else if ([buttonTitle isEqualToString:@"Adicionar aos contatos"]) {
        Jogador *jogador = [[Jogador alloc] initWithAttributes:dadosPerfilJogador];
        
        // mostra view do iOS para criar novo contato
        ABNewPersonViewController* npvc = [ABNewPersonViewController new];
        npvc.newPersonViewDelegate = self;
        npvc.displayedPerson = [[PokerGamesFacade sharedInstance] retornaContatoJogador:jogador];
        
        UINavigationController* nc = [[UINavigationController alloc] initWithRootViewController:npvc];
        [self presentViewController:nc animated:YES completion:nil];
    }
}

#pragma mark Adress book delegate methods

- (void)newPersonViewController:(ABNewPersonViewController*)newPersonViewController didCompleteWithNewPerson:(ABRecordRef)person {
    if (person) {
        [[PokerGamesFacade sharedInstance] gravaNovoContato:person];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    // Remove the mail view
    [self dismissViewControllerAnimated:TRUE completion:nil];
}


- (void) buscaPerfilJogador {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Buscando perfil";
    
    NSNumber *idJogador = nil;
    if (self.idJogadorParametro) {
        idJogador = self.idJogadorParametro;
    } else {
        idJogador = [[PokerGamesFacade sharedInstance] jogadorLogin].idJogador;
    }
    
    // busca dados da participacao do torneio
    [[PokerGamesFacade sharedInstance] buscaPerfilJogadorWithBlock:idJogador
                        constructingBodyWithBlock:^(NSDictionary *dados, NSError *error) {
                                                            
        [hud hide:YES];
                                                            
        if (error) {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Erro", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
        } else {
            // dados
            dadosPerfilJogador = dados;
            
            self.lblNome.text = [dados valueForKey:@"Nome"];
            self.lblApelido.text = [dados valueForKey:@"Apelido"];
            self.lblTelefone.text = [dados valueForKey:@"Fone"];
            self.lblEmail.text = [dados valueForKey:@"Email"];
            self.lblNascimento.text = [dados valueForKey:@"Nascimento"];
            self.lblNaturalidade.text = [dados valueForKey:@"Naturalidade"];
            
            // seta a foto do jogador
            [PokerGamesUtil setaImagemJogador:self.imgViewFoto foto:[dados valueForKey:@"Foto"]];
        }
    }];
}

@end
