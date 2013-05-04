//
//  ListaJogadoresCell.m
//  PokerGames
//
//  Created by Fabiano Rosa on 24/04/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

#import "ListaJogadoresCell.h"
#import "UIImageView+AFNetworking.h"
#import <QuartzCore/QuartzCore.h>

@implementation ListaJogadoresCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setJogador:(Jogador *)jogador
{
    _jogador = jogador;
    
    self.lblNome.text = jogador.nome;
    self.lblApelido.text = jogador.apelido;
    self.lblEmail.text = jogador.email;
    
    // seta a foto do jogador
    [self.imgViewFoto setImageWithURL:[PokerGamesUtil buildUrlFoto:jogador.foto] placeholderImage:[PokerGamesUtil imgPlaceholder]];
}

@end
