//
//  DetalhesJogadorCell.h
//  PokerGames
//
//  Created by Fabiano Rosa on 24/04/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

@interface DetalhesJogadorCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel* lblPosicao;
@property (nonatomic, weak) IBOutlet UILabel* lblEtapa;
@property (nonatomic, weak) IBOutlet UILabel* lblPontos;
@property (nonatomic, weak) IBOutlet UILabel* lblData;
@property (nonatomic, weak) IBOutlet UILabel* lblValor;
@property (nonatomic, weak) IBOutlet UIImageView* imgViewPosicao;

@property (nonatomic, strong) NSDictionary *dados;


@end
